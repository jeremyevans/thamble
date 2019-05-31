require 'rubygems'
require File.join(File.dirname(File.expand_path(__FILE__)), '../lib/thamble')
ENV['MT_NO_PLUGINS'] = '1' # Work around stupid autoloading of plugins
require 'minitest/autorun'

describe "Thamble.table" do
  def table(*a, &block)
    Thamble.table(*a, &block).gsub(/\s+\n/m, '').gsub("\n", '')
  end

  it 'should return string with HTML table for enumerable' do
    table([[1, 2]]).must_equal '<table><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should support :headers option for the headers' do
    table([[1, 2]], :headers=>%w'a b').must_equal '<table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should support :headers option as a string with comma separators' do
    table([[1, 2]], :headers=>'a,b').must_equal '<table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should support :widths option for setting width for each column' do
    table([[1, 2]], :widths=>[3,4]).must_equal '<table><colgroup><col width="3" /><col width="4" /></colgroup><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should yield each object in enumerable to block to return data row to use' do
    table([[1, 2]]){|l, t| l.map{|i| i*2}}.must_equal '<table><tbody><tr><td>2</td><td>4</td></tr></tbody></table>'
  end

  it 'should be able to create tags using the table.tag method' do
    table([[1, 2]]){|l, t| l.map{|i| t.tag(:b, i*2)}}.must_equal '<table><tbody><tr><td><b>2</b></td><td><b>4</b></td></tr></tbody></table>'
    table([[1, 2]]){|l, t| l.map{|i| t.tag(:b, i*2, i=>i)}}.must_equal '<table><tbody><tr><td><b 1="1">2</b></td><td><b 2="2">4</b></td></tr></tbody></table>'
  end

  it 'should be able to create links using the table.a method' do
    table([[1, 2]]){|l, t| l.map{|i| t.a(i*2, 'foo')}}.must_equal '<table><tbody><tr><td><a href="foo">2</a></td><td><a href="foo">4</a></td></tr></tbody></table>'
    table([[1, 2]]){|l, t| l.map{|i| t.a(i*2, 'foo', i=>i)}}.must_equal '<table><tbody><tr><td><a 1="1" href="foo">2</a></td><td><a 2="2" href="foo">4</a></td></tr></tbody></table>'
  end

  it 'should support :table option for the table attribtues' do
    table([[1, 2]], :table=>{:class=>'foo'}).must_equal '<table class="foo"><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should support :tr option for the tr attributes' do
    table([[1, 2]], :tr=>{:class=>'foo'}).must_equal '<table><tbody><tr class="foo"><td>1</td><td>2</td></tr></tbody></table>'
    table([[1, 2]], :headers=>%w'a b', :tr=>{:class=>'foo'}).must_equal '<table><thead><tr class="foo"><th>a</th><th>b</th></tr></thead><tbody><tr class="foo"><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should support :td option for the td attributes' do
    table([[1, 2]], :td=>{:class=>'foo'}).must_equal '<table><tbody><tr><td class="foo">1</td><td class="foo">2</td></tr></tbody></table>'
  end

  it 'should support :th option for the th attributes' do
    table([[1, 2]], :headers=>%w'a b', :th=>{:class=>'foo'}).must_equal '<table><thead><tr><th class="foo">a</th><th class="foo">b</th></tr></thead><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should support a proc for the :tr option' do
    table([[1, 2]], :tr=>proc{|row| {:class=>"foo#{row.join}"}}).must_equal '<table><tbody><tr class="foo12"><td>1</td><td>2</td></tr></tbody></table>'
    table([[1, 2]], :headers=>%w'a b', :tr=>proc{|row| {:class=>"foo#{row.join}"}}).must_equal '<table><thead><tr class="fooab"><th>a</th><th>b</th></tr></thead><tbody><tr class="foo12"><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should support a proc for the :td option' do
    table([[1, 2]], :td=>proc{|v, i, row| {:class=>"foo#{row.join}-#{v}-#{i}"}}).must_equal '<table><tbody><tr><td class="foo12-1-0">1</td><td class="foo12-2-1">2</td></tr></tbody></table>'
  end

  it 'should support a proc for the :th option' do
    table([[1, 2]], :headers=>%w'a b', :th=>proc{|v| {:class=>"foo#{v}"}}).must_equal '<table><thead><tr><th class="fooa">a</th><th class="foob">b</th></tr></thead><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should support :caption option for the table caption' do
    table([[1, 2]], :headers=>%w'a b', :caption=>'Foo').must_equal '<table><caption>Foo</caption><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end

  it 'should be callable as a method if including the module' do
    Class.new{include Thamble}.new.send(:table, [[1, 2]]).gsub(/\s+\n/m, '').gsub("\n", '').must_equal '<table><tbody><tr><td>1</td><td>2</td></tr></tbody></table>'
  end
end
