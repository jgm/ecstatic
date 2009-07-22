require 'rubygems'
require 'tenjin'
require 'optparse'
require 'yaml'
require 'activesupport'
require 'rake'
require 'rake/clean'
require 'find'
require 'open3'

module Ecstatic
  class Site
#    :attr_accessor :pages, :files, :sitedir, :templatesdir, :filesdir,
#                   :default_layout, :navhash, :sitetitle

#    def initialize(params)
       
#    end

    def tasks(paths = {})
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
          :format => p['format'],
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
    attr_accessor :contexthash, :layoutfile, :templatefile, :navhash, :url, :format

    def initialize(templatefile = nil, datafiles = [], layoutfile = nil, navfile = nil, url = nil, format = :html)
      @templatefile = templatefile
      @format = format
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

    def render
      engine = Tenjin::Engine.new(:cache => false, :escapefunc => 'Ecstatic.no_escape')
      context = Tenjin::Context.new(self.contexthash)
      markdown_output = engine.render(self.templatefile, context)
      cmd = case self.format
      when :html
        "pandoc -r markdown -w html --smart"
      when :latex
        "pandoc -r markdown -w latex --smart"
      when :pdf
        "pandoc -r markdown -w latex --smart | rubber-pipe --pdf"
      when :plain
        "cat"
      end
      formatted_output = Open3.popen3(cmd) do |stdin, stdout, stderr|
        stdin.write(markdown_output)
        stdin.close
        stdout.read
      end
      if self.layoutfile
         engine.render(self.layoutfile, {'_contents' => formatted_output, '_nav' => self.navhash, '_url' => self.url})
      else
         formatted_output
      end
    end

  end

  # escape functions

  def no_escape(str)
    str
  end

  def mkmenu(menu, url = nil)
    if ! menu
      return ""
    end
    _buf = []
    _buf << "<ul class=\"nav\">"
    menu.each do |item|
      if item.class == Hash
        item.each_pair do |k,v|
          if v.class == Array
            _buf << "<li>#{k}"
            _buf << mkmenu(v, url)
            _buf << "</li>"
          else
            selected = if url == v
                          " class=\"selected\""
                       else
                          ""
                       end
            _buf << "<li><a href=#{v}#{selected}>#{k}</a></li>"
          end
        end
      else
        # do nothing - shouldn't happen
      end
    end
    _buf << "</ul>"
    return _buf.join("\n")
  end

  module_function :mkmenu, :no_escape

end

