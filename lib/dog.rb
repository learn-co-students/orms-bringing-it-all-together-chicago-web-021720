require 'pry'
class Dog
  attr_accessor :id, :name, :breed
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      return self
    else
      DB[:conn].execute('INSERT INTO dogs (name,breed) VALUES(?,?)', self.name, self.breed)
      self.id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def self.create(attr)
    Dog.new(name: attr[:name], breed: attr[:breed]).save
  end

  def self.new_from_db(row)
    Dog.new(id: row[0],name: row[1],breed: row[2])
  end

  def self.find_by_id(id)
    self.new_from_db(DB[:conn].execute('SELECT * FROM dogs WHERE id=?',id)[0])
  end

  def self.find_or_create_by(attr)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', attr[:name], attr[:breed])[0]
    row ? self.new_from_db(row) : self.create({name: attr[:name], breed: attr[:breed]})
  end

  def self.find_by_name(name)
    self.new_from_db(DB[:conn].execute('SELECT * FROM dogs WHERE name=?',name)[0])
  end
  def update
    DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?',self.name,self.breed,self.id)
  end
end
