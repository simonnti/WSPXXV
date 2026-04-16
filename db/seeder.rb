require 'sqlite3'

db1 = SQLite3::Database.new("posts.db")

db2 = SQLite3::Database.new("users.db")

def seed!(db)
  puts "Using db file: posts.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"

  puts "Using db file: users.db"
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
  db.execute('DROP TABLE IF EXISTS users')
end

def create_tables(db)
  db.execute('CREATE TABLE posts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL, 
              description TEXT,
              price_type TEXT,
              price INTEGER,
              image_url TEXT,
              user_id INTEGER
              )')
  db.execute('CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE NOT NULL,
              password_digest TEXT NOT NULL
              )')
end

def populate_tables(db)
  db.execute('INSERT INTO posts (title, description, price, price_type, image_url, user_id) VALUES("Betongbarriär", "Betongbarriär uthyres. Kan användas för avskärmning av större ytor utomhus, osv. Pris: 50 kr/dag", 50, "hour", "/img/barriar.jpg", 1)')
  db.execute('INSERT INTO posts (title, description, price, price_type, image_url, user_id) VALUES("mer goy zlob", "goyslop", 100, "day", "/img/DAMN!!!!!!!!!!!!.jpg", 2)')
  db.execute('INSERT INTO posts (title, description, price, price_type, image_url, user_id) VALUES("a a hahuh", "ahahahgags", 200, "week", "/img/green_fuck.jpg", 1)')
  db.execute('INSERT INTO users (username, password_digest) VALUES ("john_doe", "fella")')
  db.execute('INSERT INTO users (username, password_digest) VALUES ("jane_doe", "password123")')
end

seed!(db1)
seed!(db2)