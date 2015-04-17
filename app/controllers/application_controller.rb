class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    @todo_array = get_test_cases_hash('C:/Users/ndsouza/Documents/horizontal_contextmenu/wsb-ruby-automation')[:data]
    render 'list-tests'
  end

  def todo_array
    #@todo_array = [ "Buy Milk", "Buy Soap", "Pay bill", "Draw Money" ]
  end

  def run_test
    call_rake(:run_test)
  end

  private

  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "/usr/bin/rake #{task} #{args.join(' ')} &"
  end

  def get_line_with_data(input_file,data)
    line_info = {:string_data=>[],:line_number=>[]}
    file = File.open(input_file.first, 'r+')
    lines_array =[]
    file.each do |line|
      lines_array << line
    end
    lines_array.each_with_index do |line, i|
      if (line.match(data))
        line_info[:string_data] << line.match(data)[1].strip
        line_info[:line_number] << i
        if data == /describe(.*)do/m
          return line_info
        end
      end
    end
    return line_info
  end

  def get_test_cases_hash(project_location)
    master_hash ={}
    test_count = 0
    master_hash[:data] = {}
    test_domain_count = 0
    Dir.glob("#{project_location}/spec/**/*.rb").each do |specfile| # enumerate the Spec files
      file_text = File.read(specfile) # downcase here if necessary
      master_hash[:data][test_domain_count] = {}
      file_name = File.basename(specfile)
      file_path =  Dir.glob("#{project_location}/**/#{file_name}")
      if !file_text.include?("# RSpec.describe")
        file_name = File.basename(specfile)
        file_path =  Dir.glob("#{project_location}/**/#{file_name}")
        describe = get_line_with_data(file_path,/describe(.*)do/m)
        master_hash[:data][test_domain_count][:domain_name] = describe[:string_data][0]
        master_hash[:data][test_domain_count][:tests] =[]

        test_name = get_line_with_data(file_path,/it (.*) do/m)
        test_name[:string_data].each_with_index do |name,i|
          master_hash[:data][test_domain_count][:tests][i] = {}
          master_hash[:data][test_domain_count][:tests][i][:test_name] = name
          master_hash[:data][test_domain_count][:tests][i][:line_number] = test_name[:line_number][i]
          master_hash[:data][test_domain_count][:tests][i][:path] =  file_path
          test_count += 1
        end
      end
      if !master_hash[:data][test_domain_count].empty? && !master_hash[:data][test_domain_count][:tests].empty?
        test_domain_count +=1
      end
    end
    master_hash[:number_of_specs] = test_domain_count
    master_hash[:total_number_of_tests] = test_count
    master_hash
  end
end
