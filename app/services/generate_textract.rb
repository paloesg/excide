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
      get_table
      get_data_table
      OpenStruct.new(success?: true, table: @table_rows)
    rescue => e
      OpenStruct.new(success?: false, table: @table_rows, message: e.message)
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
      feature_types: ["TABLES"],
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
    @blocks = @textract_json['blocks']
    @blocks_map = {}
    @table_blocks = []
    @table_result = []

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
    return @table_result
  end

  def get_rows_column(table, data)
    rows = {}
    table['relationships'].each do |relationship|
      if relationship['type'] == "CHILD"
        relationship['ids'].each do |child|
          cell = data[child]
          if cell['block_type'] == "CELL"
            row_index = cell['row_index']
            col_index = cell['column_index']
            if !(rows.has_key? row_index)
              rows[row_index] = {}
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
    if cell['relationships']
      cell['relationships'].each do |relationship|
        if relationship['type'] == "CHILD"
          relationship['ids'].each do |child|
            word = data[child]
            if word['block_type'] == "WORD"
              text += word['text']
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
    @arr_object = []
    @head_id = []
    # create object array of table
    @table_result.each do |table|
      table.each do |tab_val|
        object = {}
        tab_val.each do |col_val|
          object = col_val
        end 
        if object.present?
          @arr_object.push(object)
        end 
      end

      # find head of table
      @arr_object.each do |object|
        rows_head = {}
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
      @table_rows = [] 
      i = 0 
      @arr_object.each_with_index do |object, index|
        row_result = {}
        row_result['description'] = object[@head_id[0]['description']] if @head_id[0]['description'].present?
        row_result['price'] = object[@head_id[0]['price']].tr('$ ( )', '').to_f if @head_id[0]['price'].present?
        row_result['amount'] = object[@head_id[0]['amount']].tr('$ ( )', '').to_f if @head_id[0]['amount'].present?
        row_result['quantity'] = object[@head_id[0]['quantity']] if @head_id[0]['quantity'].present?
        row_result['index'] = index
        if row_result.present?
          @table_rows.push(row_result)
        end
      end
    end

    # remove first array, because that is as head of table
    @table_rows.shift

    return @table_rows
  end
end