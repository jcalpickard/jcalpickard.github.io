module Jekyll
  class TagPageGenerator < Jekyll::Generator
    safe true

    def generate(site)
      tags = site.collections['compost'].docs.flat_map { |d| d.data['tags'] || [] }.to_set
      tags.each do |tag|
        site.pages << TagPage.new(site, site.source, tag, tag)
      end
    end
  end

  class TagPage < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir  = File.join('compost/tags', dir) # Adjusted to ensure correct path
      @name = 'index.html'
      
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag'] = tag
      self.data['title'] = "Tagged: #{tag}"
      self.data['permalink'] = "/compost/tags/#{tag}/"
    end
  end
end