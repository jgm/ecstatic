require 'rubygems'
require 'tenjin'
require 'optparse'
require 'yaml'
require 'markdown'
require 'activesupport'

module Ecstatic
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

