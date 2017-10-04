require 'bundler'
Bundler.require
require 'open-uri'

%w(data_cache with_cache blog).each do |f|
  require_relative "src/#{f}"
end

class App < Sinatra::Base
  before { content_type :json }

  set :show_exceptions, :after_handler
  error 500 { {error: env['sinatra.error'].message}.to_json }
  error 404 { {error: 'Not implement yet!!' }.to_json }

  get '/categories' do
    Blog.categories.to_json
  end

  get '/category/:name/article-count' do |category_name|
    blog = Blog.new(category_name)
    { total_articles: blog.article_count }.to_json
  end
end

run App