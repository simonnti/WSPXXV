require 'sqlite3'

db = SQLite3::Database.new("posts.db")

def seed!(db)
  puts "Using db file: posts.db"
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
              title TEXT NOT NULL, 
              description TEXT,
              price INTEGER,
              image_url TEXT)')
end

def populate_tables(db)
  db.execute('INSERT INTO posts (title, description, image_url) VALUES ("Goyslop", "säljer denna goyslop bilig", "/img/blowie.jpg")')
  db.execute('INSERT INTO posts (title, description, image_url) VALUES ("mer goy zlob", "goyslop", "/img/DAMN!!!!!!!!!!!!.jpg")')
  db.execute('INSERT INTO posts (title, description, image_url) VALUES ("a a hahuh", "ahahahgags", "/img/green_fuck.jpg")')
end

seed!(db)