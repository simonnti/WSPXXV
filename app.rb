require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

get('/') do
  db = SQLite3::Database.new("db/posts.db")
  id = params[:id].to_i
  db.results_as_hash = true
  db.execute("PRAGMA encoding = 'UTF-8'")
  @posts = db.execute("SELECT * FROM posts")
  slim(:home)
end

post('/upload') do
  db = SQLite3::Database.new("db/posts.db")
  db.results_as_hash = true

  title = params[:title]
  description = params[:description]
  price = params[:price].to_f
  price_type = params[:price_type]

  if params[:image] && params[:image][:tempfile] && params[:image][:filename]
    tempfile = params[:image][:tempfile]
    filename = params[:image][:filename]

    save_path = "./public/img/#{filename}"
    File.open(save_path, "wb") do |f|
      f.write(tempfile.read)
    end

    image_url = "/img/#{filename}"
  else
    image_url = nil
  end

  db.execute(
  "INSERT INTO posts (title, description, price, price_type, image_url, user_id)
   VALUES (?, ?, ?, ?, ?, ?)",
  [title, description, price, price_type, image_url, session[:user_id]]
  )

  redirect('/')
end

get('/upload') do
  if session[:user_id]
    slim(:upload)
  else
    redirect('/login')
  end
end

post("/:id/return") do
    redirect('/')
end

get('/:id/post') do
  db = SQLite3::Database.new("db/posts.db")
  id = params[:id].to_i
  db.results_as_hash = true
  @posts = db.execute("SELECT * FROM posts WHERE id = ?", id).first
  slim(:post)
end

get('/register') do
  slim(:register)
end

post('/register') do
  db = SQLite3::Database.new("db/users.db")

  username = params[:username]
  password = params[:password]

  password_digest = BCrypt::Password.create(password)

  db.execute(
    "INSERT INTO users (username, password_digest) VALUES (?, ?)",
    [username, password_digest]
  )

  redirect('/login')
end

get('/login') do
  slim(:login)
end

post('/login') do
  db = SQLite3::Database.new("db/users.db")
  db.results_as_hash = true

  username = params[:username]
  password = params[:password]

  user = db.execute("SELECT * FROM users WHERE username = ?", [username]).first

  if user && BCrypt::Password.new(user["password_digest"]) == password
    session[:user_id] = user["id"]
    redirect('/')
  else
    @error = "Fel användarnamn eller lösenord"
    slim(:login)
  end
end

get('/logout') do
  session.clear
  redirect('/')
end

get('/myads') do
  if session[:user_id]
    db = SQLite3::Database.new("db/posts.db")
    db.results_as_hash = true
    @posts = db.execute("SELECT * FROM posts WHERE user_id = ?", session[:user_id])
    slim(:myads)
  else
    redirect('/login')
  end
end