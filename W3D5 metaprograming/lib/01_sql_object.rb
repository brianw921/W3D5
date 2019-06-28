require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    #lazy initiliazation ||= so that the query is not multiple times. Only queries the DB once
    #execute 2 will return an array where the first element is an array and everything else is a hash
    @array ||= DBConnection.execute2(<<-SQL )
    SELECT
      *
    FROM
      #{self.table_name}
  SQL
  @column = @array.first.map(&:to_sym)
  end

  def self.finalize!
    
    self.columns.each do |attribute|
      self.define_method attribute do
        @attributes[attribute]
      end
      self.define_method "#{attribute}=" do |value|
        self.attributes[attribute] = value
      end
    end
  end


  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
   
    @table_name ||= "#{name}".tableize
  end

  def self.all
   variable = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
  SQL
  
  self.parse_all(variable)
  end

  def self.parse_all(results)
    results.map {|result| self.new(result)}
  end

  def self.find(id)
    DBConnection.execute(<<-SQL)
    SELECT
      id
    FROM
      #{self.table_name}
    WHERE
      id = #{id}
    SQL
    
  end

  def initialize(params = {})
    
    params.each do |k,v|
      raise "unknown attribute \'#{k.to_sym}\'" unless self.class.columns.include?(k.to_sym)
      
      self.send("#{k.to_sym}=",v)
    end 
    
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
      
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
