require 'sqlite3'

db = SQLite3::Database.new("database.db")

def seed!(db)
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
  db.execute('INSERT INTO posts (title, description, price, price_type, image_url, user_id) VALUES("Betongbarriär", "Betongbarriär uthyres. Kan användas för avskärmning av större ytor utomhus, osv. Pris: 50 kr/vecka", 50, "week", "/img/barriar.jpg", 1)')
  db.execute('INSERT INTO users (username, password_digest) VALUES("john", "$2a$12$eG8m9n7u5l3Zt1Xo5j6b0u9v8w7x6y5z4a3b2c1d0e9f8g7h6i")')
end

seed!(db)