namespace :jquery do
  desc "Downloads the latest stable code from Google's APIs"
  task :download do
    require "uri"
    %w( http://ajax.googleapis.com/ajax/libs/jquery/1.2/jquery.min.js
        http://ajax.googleapis.com/ajax/libs/jquery/1.2/jquery.js
        http://ajax.googleapis.com/ajax/libs/jqueryui/1.5/jquery-ui.min.js
        http://ajax.googleapis.com/ajax/libs/jqueryui/1.5/jquery-ui.js).each do |url|
      Dir.chdir("public/javascripts") do
        uri = URI.parse(url)
        filename = File.basename(uri.path)
        puts "#{url} => #{filename}"
        sh "curl -s -o #{filename} #{url}"
      end
    end
  end
end
