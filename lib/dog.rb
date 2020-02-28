class Dog
    attr_accessor :name, :breed
    attr_reader :id
    
    # Initialize macro
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    # Class methods
    def self.create_table
        DB[:conn].execute(
        "CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            breed TEXT,
            name TEXT
            )")
    end

    def self.drop_table
        DB[:conn].execute(
            "DROP TABLE IF EXISTS dogs"
        )
    end

    def self.create(name:, breed:, id: nil)
        dog = Dog.new(name: name, breed: breed, id: id)
        dog.save
        dog
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute(
            "SELECT * FROM dogs
            WHERE name = ? AND breed = ?", name, breed).first
        if dog
            dog = self.new_from_db(dog)
        else
            dog = self.create(name: name, breed: breed)
        end
    end

    def self.find_by_id(id)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
        dog ? self.new_from_db(dog) : nil
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
        dog ? self.new_from_db(dog) : nil
    end

    # Instance methods
    def save
        if @id
            self.update
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES ( ?, ? )", @name, @breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        DB[:conn].execute(
            "UPDATE dogs SET name = ?, breed = ?
            WHERE id = ?", @name, @breed, @id)
    end

end