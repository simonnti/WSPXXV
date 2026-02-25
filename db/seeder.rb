require 'sqlite3'

db = SQLite3::Database.new("databas.db")

def seed!(db)
  puts "Using db file: db/todos.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS posts')
end

def create_tables(db)
  db.execute('CREATE TABLE posts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT,
              price INTEGER)')
end

def populate_tables(db)
  db.execute('INSERT INTO posts (name, description) VALUES ("Goyslop", "säljer denna goyslop bilig")')
  db.execute('INSERT INTO posts (name, description) VALUES ("mer goy zlob", "goyslop")')
  db.execute('INSERT INTO posts (name, description) VALUES ("a a hahuh", "ahahahgags")')
end

def img_to_hex(db)
  image_path = 'path/to/your/image.png'
  binary_data = File.read(image_path)
  hex_key = binary_data.unpack('H*').first
end

seed!(db)