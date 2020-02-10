class GenerateTextract
  def initialize(document_id)
    @document_id = document_id
  end

  def run_generate
    begin
      get_document
      generate_textract
      @document.save
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  def run_analyze
    begin
      get_document
      analyze_document
      get_table # convert json textract to json table
      get_data_table # convert json table to json array with fix format 
      get_form # get total amount from textract
      OpenStruct.new(success?: true, tables: @table_rows, forms: @kvs)
    rescue => e
      OpenStruct.new(success?: false, tables: @table_rows, forms: @kvs, message: e.message)
    end
  end

  private

  def get_document
    @document = Document.find(@document_id)
  end

  def generate_textract
    # get object file location and name
    s3_uri = URI.parse(@document.file_url)
    s3_uri.path.slice!(0)
    file_name = s3_uri.path
    # example: "excide/uploads/3d8ff957-532b-4f37-8fbe-9baa522d337c/191126-fuji-xerox-250-87.pdf"

    # asynchronus operation
    resp = AWS_TEXTRACT.start_document_analysis({
      document_location: {
        s3_object: {
          bucket: ENV['S3_BUCKET'],
          name: file_name
        }
      },
      feature_types: ["TABLES", "FORMS"],
      job_tag: "Receipt",
    })
    @document.aws_textract_job_id = resp[:job_id]
  end

  def analyze_document
    job_id = @document.aws_textract_job_id
    @textract_json = AWS_TEXTRACT.get_document_analysis({
      job_id: job_id.to_s
    })
    return @textract_json
  end

  def get_table
    @table_result = Array.new()
    # validate if aws textract data has in database
    if @document.aws_textract_data.present?
      @table_result = @document.aws_textract_data
    else
      @blocks = @textract_json['blocks']
      @blocks_map = Hash.new()
      @table_blocks = Array.new()
      @forms = Array.new()

      @blocks.each do |block|
        @blocks_map[block['id']] = block
        if block['block_type'] == "TABLE"
          @table_blocks.push(block)
        end
      end

      @table_blocks.each do |table|
        result = get_rows_column(table, @blocks_map)      
        @table_result.push(result)
      end
      # save aws textract data to database
      @document.aws_textract_data = @table_result
      @document.save 
    end    
    return @table_result
  end


  def get_form
    @blocks = @textract_json['blocks']
    # get key and value maps
    @key_map = Array.new()
    @value_map = Array.new()
    @block_map = Hash.new()

    @blocks.each do |block|
      block_id = block['id']
      @block_map[block_id] = block
      if block['block_type'] == "KEY_VALUE_SET"
        if block['entity_types'].include? "KEY"
          @key_map.push(block)
        else
          @value_map.push(block)
        end
      end
    end

    @kvs = Array.new()
    @key_map.each do |key_block|
      f = Hash.new()
      @value_block = find_value_block(key_block, @value_map)
      key = get_text(key_block, @block_map)
      val = get_text(@value_block, @block_map)
      # get only total amount
      if key.include? "total" or key.include? "Total"
        fix_value = val.gsub(/[^\d\.]/, '').to_f if val.present?
        f['total_amount'] = fix_value
        @kvs.push(f)
      end
    end
    return @kvs
  end

  def find_value_block(key_block, value_map)
    key_block['relationships'].each do |relationship|
      if relationship['type'] == 'VALUE'
        relationship['ids'].each do |value_id|
          @value_block = value_map.find{|h| h['id'] == value_id}
        end
      end
    end
    return @value_block
  end

  def get_rows_column(table, data)
    rows = Hash.new()
    table['relationships'].each do |relationship|
      if relationship['type'] == "CHILD"
        relationship['ids'].each do |child|
          cell = data[child]
          if cell['block_type'] == "CELL"
            row_index = cell['row_index']
            col_index = cell['column_index']
            unless rows.key?(row_index)
              rows[row_index] = Hash.new()
            end
            rows[row_index][col_index] = get_text(cell, data)
          end
        end
      end
    end
    return rows
  end

  def get_text(cell, data)
    text = ""
    if cell['relationships'].present?
      cell['relationships'].each do |relationship|
        if relationship['type'] == "CHILD"
          relationship['ids'].each do |child|
            word = data[child]
            if word['block_type'] == "WORD"
              text += word['text']+ ' '
            end
            if word['block_type'] == "SELECTION_ELEMENT"
              if word['selection_status'] == "SELECTED"
                text += 'X '
              end
            end
          end
        end
      end
    end
    return text
  end

  def get_data_table
    # create object array of table    
    @table_rows = Array.new()
    @table_result.each do |table|
      @arr_object = Array.new()
      @head_id = Array.new()
      table.each do |tab_val|
        object = Hash.new()
        tab_val.each do |col_val|
          object = col_val
        end 
        if object.present?
          @arr_object.push(object)
        end 
      end

      if @arr_object.present?
        # find head of table
        @arr_object.each do |object|
          rows_head = Hash.new()
          object.each do |ass|
            rows_head['price'] = ass[0] if ass[1].include? "price" or ass[1].include? "Price"
            rows_head['amount'] = ass[0] if ass[1].include? "amount" or ass[1].include? "Amount"
            rows_head['description'] = ass[0] if ass[1].include? "description" or ass[1].include? "Description"
            rows_head['quantity'] = ass[0] if ass[1].include? "quantity" or ass[1].include? "Quantity"
          end

          if rows_head.present?
            @head_id.push(rows_head)
          end 
        end

        # find values by head of table 
        if @head_id.present?
          @arr_object.each_with_index do |object, index|
            row_result = Hash.new()
            row_result['description'] = object[@head_id[0]['description']] if @head_id[0]['description'].present?
            row_result['price'] = object[@head_id[0]['price']].gsub(/[^\d\.]/, '').to_f if @head_id[0]['price'].present? && object[@head_id[0]['price']].present?
            row_result['amount'] = object[@head_id[0]['amount']].gsub(/[^\d\.]/, '').to_f if @head_id[0]['amount'].present? && object[@head_id[0]['amount']].present?
            row_result['quantity'] = object[@head_id[0]['quantity']] if @head_id[0]['quantity'].present?
            row_result['index'] = index
            if row_result.present?
              @table_rows.push(row_result)
            end
          end
        end 
      end           
    end

    # remove first array, because that is as head of table
    @table_rows.shift
    return @table_rows
  end
end