# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
commercial = ProjectCategory.create({ name: 'Commercial', status: 'active' })
ProjectCategory.create([{ name: 'Business Plan', status: 'active', parent: commercial }, { name: 'Corporate Finance', status: 'active', parent: commercial }, { name: 'Corporate Strategy', status: 'active', parent: commercial }, { name: 'Competitive Analysis', status: 'active', parent: commercial }, { name: 'Digital Marketing', status: 'active', parent: commercial }, { name: 'Financial Projections and Analysis', status: 'active', parent: commercial }, { name: 'Market Analysis and Research', status: 'active', parent: commercial }, { name: 'Marketing Collateral', status: 'active', parent: commercial }, { name: 'Mergers and Acquisitions', status: 'active', parent: commercial }, { name: 'Public Relations', status: 'active', parent: commercial }, { name: 'Presentation Development', status: 'active', parent: commercial }, { name: 'Pricing Strategy', status: 'active', parent: commercial }, { name: 'Raise Capital and Funding', status: 'active', parent: commercial }, { name: 'Risk Advisory', status: 'active', parent: commercial }, { name: 'SWOT Analysis', status: 'active', parent: commercial }, { name: 'Treasury Advisory', status: 'active', parent: commercial }, { name: 'Valuation', status: 'active', parent: commercial }])
operations = ProjectCategory.create({ name: 'Operations', status: 'active' })
ProjectCategory.create([{ name: 'Business Outsource', status: 'active', parent: operations }, { name: 'Corporate Website', status: 'active', parent: operations }, { name: 'Corporate Insurance', status: 'active', parent: operations }, { name: 'Corporate Training', status: 'active', parent: operations }, { name: 'Employee Benefits', status: 'active', parent: operations }, { name: 'Human Resource', status: 'active', parent: operations }, { name: 'IT Consulting', status: 'active', parent: operations }, { name: 'Mobile App Development', status: 'active', parent: operations }, { name: 'Performance Metric and Benchmark', status: 'active', parent: operations }, { name: 'Process Engineering and Improvement', status: 'active', parent: operations }, { name: 'Supply Chain', status: 'active', parent: operations }, { name: 'System Solutions', status: 'active', parent: operations }, { name: 'Web Platform Development', status: 'active', parent: operations }])
accounting = ProjectCategory.create({ name: 'Accounting', status: 'active' })
ProjectCategory.create([{ name: 'Accounting System', status: 'active', parent: accounting }, { name: 'Audit Services', status: 'active', parent: accounting }, { name: 'Corporate Secretarial', status: 'active', parent: accounting }, { name: 'IPO Compliance', status: 'active', parent: accounting }, { name: 'Part-Time CFO', status: 'active', parent: accounting }, { name: 'Tax Compliance', status: 'active', parent: accounting }, { name: 'Tax Consulting', status: 'active', parent: accounting }])
legal = ProjectCategory.create({ name: 'Legal', status: 'active' })
ProjectCategory.create([{ name: 'Contract Drafting', status: 'active', parent: legal }, { name: 'Employment Contract', status: 'active', parent: legal }, { name: 'Financing Documents', status: 'active', parent: legal }, { name: 'IP & Franchising', status: 'active', parent: legal }, { name: 'JV Formation', status: 'active', parent: legal }, { name: 'Sales and Purchase Negotiations', status: 'active', parent: legal }, { name: 'Trademark Advice', status: 'active', parent: legal }])
country = ProjectCategory.create({ name: 'Country Knowledge Network', status: 'active' })
ProjectCategory.create([{ name: 'Sub-contract Agreements', status: 'active', parent: country }, { name: 'Hourly Consultations', status: 'active', parent: country }, { name: 'Industry Reports', status: 'active', parent: country }])
industry = ProjectCategory.create({ name: 'Industry Knowledge Network', status: 'active' })
ProjectCategory.create([{ name: 'Sub-contract Agreements', status: 'active', parent: industry }, { name: 'Hourly Consultations', status: 'active', parent: industry }, { name: 'Industry Reports', status: 'active', parent: industry }])
others = ProjectCategory.create({ name: 'Others', status: 'active' })
ProjectCategory.create({ name: 'Others', status: 'active', parent: others })

company = Company.create(name: 'Gobbler')
admin = User.create(email: 'admin@gobbler.com', password: 'password', first_name: 'Admin', last_name: 'Gobbler', contact_number: '12341234', company: company)
admin.add_role :admin, company
sales = User.create(email: 'sales@gobbler.com', password: 'password', first_name: 'Sales', last_name: 'Gobbler', contact_number: '12341234', company: company)
sales.add_role :sales, company
sales_support = User.create(email: 'sales_support@gobbler.com', password: 'password', first_name: 'Sales Support', last_name: 'Gobbler', contact_number: '12341234', company: company)
sales_support.add_role :sales_support, company
procurement = User.create(email: 'procurement@gobbler.com', password: 'password', first_name: 'Procurement', last_name: 'Gobbler', contact_number: '12341234', company: company)
procurement.add_role :procurement, company
finance = User.create(email: 'finance@gobbler.com', password: 'password', first_name: 'Finance', last_name: 'Gobbler', contact_number: '12341234', company: company)
finance.add_role :finance, company
management = User.create(email: 'management@gobbler.com', password: 'password', first_name: 'Management', last_name: 'Gobbler', contact_number: '12341234', company: company)
management.add_role :management, company
vp_sales = User.create(email: 'vp_sales@gobbler.com', password: 'password', first_name: 'VP Sales', last_name: 'Gobbler', contact_number: '12341234', company: company)
vp_sales.add_role :vp_sales, company