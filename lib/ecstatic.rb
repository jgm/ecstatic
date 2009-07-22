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
    attr_accessor :pages, :files, :sitedir, :templatesdir, :datadir, :filesdir,
                   :default_layout, :navfile, :navhash, :sitetitle, :modelsdir

    def initialize(params = {})
      @sitedir = params[:sitedir] || "site"
      @default_layout = params[:layoutfile] || "standard.rbhtml"
      @filesdir = params[:filesdir] || "files"
      @modelsdir = params[:modelsdir] || "models"
      @sitetitle = params[:sitetitle] || ""
      @templatesdir = params[:templatesdir] || "."
      @datadir = params[:datadir] || "."
      @navfile = params[:navfile] || "sitenav.yaml"
      index = params[:indexfile] || "siteindex.yaml"

      siteindex = YAML::load File.read(index)

      # load user-defined data models
      Find.find(@modelsdir) do |f|
        require f unless f == @modelsdir
      end

      # construct navigation map
      @navhash = if @navfile
                    YAML::load(File.open(@navfile).read)
                 end

      # construct list of pages
      @pages = {}
      siteindex.each do |p|
        dest = File.join @sitedir, p['url']
        @pages[dest] = Page.new({
          :url => p['url'],
          :title => p['title'],
          :layoutfile => p['layout'] || @default_layout,
          :templatefile => File.join(@templatesdir, p['template']),
          :format => if p['format']
                        p['format'].to_sym
                    else
                        :html
                    end,
          :navhash => @navhash,
          :datafiles => if p['data'].class == Array
                           File.join @datadir, p['data']
                        elsif p['data'].class == String
                           [p['data']].map {|x| File.join @datadir, x}
                        else
                           []
                        end
          })
      end

      # construct hash of files
      @files = {}
      Find.find(@filesdir) do |f|
        if f != @filesdir
          base = f.gsub(/^[^\/]*\//,"")
          @files[File.join(@sitedir, base)] = f
        end
      end

    end

    def tasks

      CLEAN.include(sitedir)

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
        file dest => ([page.templatefile, page.layoutfile, self.navfile] + page.datafiles) do
          output = page.render
          File.open(dest, 'w').write(output)
          $stderr.puts "rendered #{dest}"
        end
      end

      desc "Build website in '#{sitedir}' directory."
      task :website => [sitedir] + pages.keys + files.keys

    end
  end

  class Page
    attr_accessor :datafiles, :contexthash, :layoutfile, :templatefile, :url, :format, :title, :navhash

    def initialize(params)
      @templatefile = params[:templatefile]
      @title = params[:title]
      @format = params[:format]
      @layoutfile = params[:layoutfile]
      @navhash = params[:navhash]
      @url = params[:url]
      @datafiles = params[:datafiles] || []
      # get context from data files
      @contexthash = {}
      @datafiles.each do |file|
        yamltext = File.open(file).read
        yaml = YAML::load(yamltext)
        # if YAML is not a hash, make a hash with file's basename as key:
        unless yaml.class == Hash
          yaml = {File.basename(file, File.extname(file)) => yaml}
        end
        yaml.each_pair do |key,val|
          model = key.singularize.capitalize
          begin
            mod = Object.const_get(model)
            begin
              @contexthash[key] = mod.from_array(val)
            rescue
              $stderr.puts("Unable to initialize " + key + " from model " + model)
              throw :unable_to_initialize
            end
          rescue
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
            _buf << "<li#{selected}><a href=#{v}>#{k}</a></li>"
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

