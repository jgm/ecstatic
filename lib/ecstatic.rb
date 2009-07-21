require 'rubygems'
require 'tenjin'
require 'optparse'
require 'yaml'
require 'markdown'
require 'activesupport'
require 'rake'
require 'rake/clean'
require 'find'

module Ecstatic
  class Tasks
    def self.website(paths = {})
      sitedir = paths[:sitedir] || "site"
      layout = paths[:layoutfile] || "standard.rbhtml"
      navfile = paths[:navfile] || "sitenav.yaml"
      index = paths[:indexfile] || "siteindex.yaml"
      filesdir = paths[:filesdir] || "files"
      modelsdir = paths[:modelsdir] || "models"

      CLEAN.include(sitedir)

      siteindex = YAML::load File.read(index)

      # load user-defined data models
      Find.find(modelsdir) do |f|
        require f unless f == modelsdir
      end

      # construct list of pages
      pages = {}
      siteindex.each do |p|
        dest = File.join sitedir, p['url']
        pages[dest] = {
          :url => p['url'],
          :title => p['title'],
          :template => p['template'],
          :data => if p['data'].class == Array
                      p['data']
                   elsif p['data'].class == String
                      [p['data']]
                   else
                      []
                   end }
      end

      # construct hash of files
      files = {}
      Find.find(filesdir) do |f|
        if f != filesdir
          base = f.gsub(/^[^\/]*\//,"")
          files[File.join(sitedir, base)] = f
        end
      end

      directory sitedir

      files.each_pair do |dest,src|
        file dest => src do
          d = File.dirname dest
          if ! File.exists?(d)
              mkdir_p d
          end
          if ! File.directory? dest
            cp src, dest
          end
        end
      end

      pages.each_pair do |dest,page|
        file dest => ([page[:template], layout, navfile] + page[:data]) do
          output = Ecstatic::Page.new(page[:template], page[:data], layout, navfile, page[:url]).to_html
          File.open(dest, 'w').write(output)
        end
      end

      desc "Build website in '#{sitedir}' directory."
      task :website => [sitedir] + pages.keys + files.keys

    end
  end

  class Page
    attr_accessor :contexthash, :layoutfile, :templatefile, :navhash, :url

    def initialize(templatefile = nil, datafiles = [], layoutfile = nil, navfile = nil, url = nil)
      @templatefile = templatefile
      @layoutfile = layoutfile
      @url = url
      @navhash = if navfile
                    YAML::load(File.open(navfile).read)
                 else
                    nil
                 end
      # get context from data files
      @contexthash = {}
      datafiles.each do |file|
        yamltext = File.open(file).read
        yaml = YAML::load(yamltext)
        # if YAML is not a hash, make a hash with file's basename as key:
        unless yaml.class == Hash
          yaml = {File.basename(file, File.extname(file)) => yaml}
        end
        yaml.each_pair do |key,val|
          model = key.singularize.capitalize
          begin
            @contexthash[key] = Object.const_get(model).from_array(val)
          rescue
            $stderr.puts("Unable to initialize " + key + " from model " + model)
            @contexthash[key] = val
          end
        end
      end
    end

    def escapefun(format)
      case
      when format == :html
        return 'Ecstatic.markdown_to_compact_html'
      when format == :latex
        return 'Ecstatic.markdown_to_latex'
      else
        return 'escape'
      end
     end

     def to_format(format)
      engine = Tenjin::Engine.new(:cache => false, :escapefunc => escapefun(format))

      if File.extname(self.templatefile) == '.markdown'
        contents = File.open(self.templatefile).read
        output = case
                 when format == :html
                    Ecstatic.markdown_to_compact_html(contents)
                 when format == :latex
                    Ecstatic.markdown_to_latex(contents)
                 else
                    escape(contents)
                 end
      else
        context = Tenjin::Context.new(self.contexthash)
        output = engine.render(self.templatefile, context)
      end

      if self.layoutfile
        return engine.render(self.layoutfile, {'_contents' => output, '_nav' => self.navhash, '_url' => self.url})
      else
        return output
      end
    end

    def to_html
      self.to_format(:html)
    end

    def to_latex
      self.to_format(:latex)
    end

    def to_plain
      self.to_format(:plain)
    end
  end

  # escape functions

  def markdown_to_html(str)
    Markdown.new(str, :smart).to_html
  end

  def markdown_to_compact_html(str)
    res = markdown_to_html(str)
    if (res =~ /<p>.*<p>/)
      return res
    else  # only one paragraph
      return res.gsub(/<\/?p>/,"")
    end
  end

  def markdown_to_latex(str)
    Markdown.new(str, :smart).to_latex
  end

  alias m markdown_to_html
  module_function :markdown_to_html, :markdown_to_compact_html, :markdown_to_latex, :m

end

