class Blog
  include WithCache

  BLOG_URL = "https://blog.hubstaff.com/"
  attr_reader :category

  def initialize(category)
    @category = Blog.categories[category.to_sym]
    raise "Invalid category: #{category}" if @category.nil?
  end

  def base_url
    category[:url]
  end

  def page(number)
    Blog.parser_for(File.join(base_url, "page/#{number}"))
  end

  def total_pages_in(html)
    (elem = (html/'#pagination .pagination li a').last) ? elem.attr('href').split('/').last.to_i : 1
  end

  def articles_in_page(html)
    (html/('.blog-masonry article')).count
  end

  def base_info
    @base_info ||= begin
      html = page(1)
      {
        articles_per_page: articles_in_page(html),
        total_pages: total_pages_in(html)
      }
    end
  end

  def articles_per_page; base_info[:articles_per_page]; end
  def total_pages; base_info[:total_pages]; end

  def last_page_article_count
    total_pages > 1 ? articles_in_page(page(total_pages)) : articles_per_page
  end

  def article_count
    with_cache(category[:slug]) do
      (articles_per_page * (total_pages - 1)) + last_page_article_count
    end
  end

  def self.categories
    with_cache('categories') do
      html = parser_for(BLOG_URL)
      (html/'#main-nav li a').reduce({}) do |h, elem|
        slug = elem.text.downcase.gsub(/\s+/, '-')
        h.merge!( slug.to_sym => { url: elem.attr('href'), name: elem.text, slug: slug })
      end
    end
  end

  def self.parser_for(url)
    Nokogiri::HTML(open(url).read)
  end
end