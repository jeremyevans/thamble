# frozen-string-literal: true

# Thamble exposes a single method named table to make it easy to generate
# an HTML table from an enumerable.
module Thamble
  # Empty frozen hash used for default option hashes
  OPTS = {}.freeze

  # Return a string containing an HTML table representing the data from the
  # enumerable.  +enum+ should be an enumerable containing the data.  If a block
  # is given, it is yielded each element in +enum+, and should return an array
  # representing the table data to use for that row.
  #
  # Options:
  #
  # :caption :: A caption for the table
  # :column_th :: Use th instead of td for the first cell in each row in the
  #               body.
  # :headers :: The headers to use for the table, as an array of strings or a
  #             single string using commas as the separtor.
  # :table :: HTML attribute hash for the table itself
  # :td :: HTML attribute hash for the table data cells, can be a proc called
  #        with the data value, row position, and row that returns a hash
  # :th :: HTML attribute hash for the table header cells, can be a proc called
  #        with the header that returns a hash
  # :tr :: HTML attribute hash for the table rows, can be a proc called with
  #        the row that returns a hash
  # :widths :: An array of widths to use for each column
  def table(enum, opts=OPTS)
    t = Table.new(opts)
    enum.each do |row|
      row = yield(row, t) if block_given?
      t << row
    end
    t.to_s
  end
  module_function :table

  # Return a raw string, which will not be HTML escaped in Thamble's output.
  def raw(s)
    RawString.new(s)
  end
  module_function :raw

  # The Table class stores the rows and attributes to use for the HTML tags,
  # and contains helper methods for common formatting.
  class Table
    # Create a new Table instance.  Usually not called directly,
    # but through Thamble.table.
    def initialize(opts=OPTS)
      @opts = opts
      @rows = []
    end

    # Add a row to the table.
    def <<(row)
      @rows << row
    end

    # Return a string containing the HTML table.
    def to_s
      empty = ''.freeze
      tr = 'tr'.freeze
      th = 'th'.freeze
      td = 'td'.freeze
      nl = "\n".freeze
      tr_attr = @opts[:tr]
      th_attr = @opts[:th]
      td_attr = @opts[:td]
      col_th = @opts[:column_th]

      t = tag('table', empty, @opts[:table])
      s = t.open.dup
      s << nl

      if caption = @opts[:caption]
        s << tag(:caption, caption).to_s
      end

      if widths = @opts[:widths]
        s << "<colgroup>\n"
        widths.each do |w|
          s << "<col width=\"#{w.to_i}\" />\n"
        end
        s << "</colgroup>\n"
      end

      if headers = @opts[:headers]
        s << "<thead>\n"
        headers = headers.split(',') if headers.is_a?(String)
        trh = tag(tr, empty, handle_proc(tr_attr, headers))
        s << trh.open
        s << nl
        headers.each_with_index do |header, i|
          s << tag(th, header, handle_proc(th_attr, header)).to_s
        end
        s << trh.close
        s << "</thead>\n"
      end

      s << "<tbody>\n"
      @rows.each do |row|
        trh = tag(tr, empty, handle_proc(tr_attr, row))
        s << trh.open
        s << nl
        row.each_with_index do |col, i|
          s << tag((col_th && i == 0 ? th : td), col, handle_proc(td_attr, col, i, row)).to_s
        end
        s << trh.close
      end
      s << "</tbody>\n"
      s << t.close
    end

    # Create a Tag object from the arguments.
    def tag(*a)
      Tag.tag(*a)
    end

    # Create an a tag with the given text and href.
    def a(text, href, opts=OPTS)
      tag('a', text, opts.merge(:href=>href))
    end

    # Return a Raw string, which won't be HTML escaped.
    def raw(s)
      RawString.new(s)
    end

    private

    # If pr is a Proc or Method, call it with the given arguments,
    # otherwise return it directly.
    def handle_proc(pr, *a)
      case pr
      when Proc, Method
        pr.call(*a)
      else
        pr
      end
    end
  end

  # Module that can be included into other String subclasses so
  # that the instances are not HTML escaped
  module Raw
  end

  # Simple subclass of string, where instances are not HTML
  # escaped.
  class RawString < String
    include Raw
  end

  # Tags represent an individual HTML tag.
  class Tag
    # The type of the tag
    attr_reader :type

    # If the given content is already a Tag instance with the
    # same type, return it directly, otherwise create a new
    # Tag instance with the given arguments.
    def self.tag(type, content='', attr=nil)
      if content.is_a?(Tag) && content.type.to_s == type.to_s 
        content
      else
        new(type, content, attr)
      end
    end

    # Create a new instance.  Usually not called
    # directly, but through Tag.tag. 
    def initialize(type, content='', attr=nil)
      @type, @content, @attr = type, content, attr||OPTS
    end

    # A string for the HTML to use for this tag.
    def to_s
      "#{open}#{content}#{close}"
    end

    # A string for the opening HTML for the tag.
    def open
      "<#{@type}#{' ' unless @attr.empty?}#{attr}>"
    end

    # A string for the inner HTML for the tag.
    def content
      h @content
    end

    # A string for the closing HTML for the tag.
    def close
      "</#{@type}>\n"
    end

    private

    # A string for the html attributes for the tag.
    def attr
      @attr.map{|k,v| "#{k}=\"#{h v}\""}.sort.join(' ')
    end
    
    begin
      require 'cgi/escape'
    rescue LoadError
      # :nocov:
      # Handle old Ruby versions not supporting cgi/escape
      require 'cgi'
    else
      unless CGI.respond_to?(:escapeHTML) # work around for JRuby 9.1
        CGI = Object.new
        CGI.extend(defined?(::CGI::Escape) ? ::CGI::Escape : ::CGI::Util)
      end
      # :nocov:
    end

    def escape_html(value)
      CGI.escapeHTML(value.to_s)
    end

    # A HTML-escaped version of the given argument.
    def h(s)
      case s
      when Raw
        s
      when Tag
        s.to_s
      else
        escape_html(s)
      end
    end
  end
end
