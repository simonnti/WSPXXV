require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

get('/') do
  db = SQLite3::Database.new("db/posts.db")
  id = params[:id].to_i
  db.results_as_hash = true
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
    filename = filename.force_encoding("UTF-8")
    filename = filename.gsub(/[^0-9A-Za-z.\-]/, "_")

    save_path = "./public/img/#{filename}"

    File.open(save_path, "wb") do |f|
      f.write(tempfile.read)
    end

    image_url = "/img/#{filename}"
  else
    image_url = nil
  end

  db.execute(
    "INSERT INTO posts (title, description, price_type, price, image_url, user_id)
     VALUES (?, ?, ?, ?, ?, ?)",
    [title, description, price_type, price, image_url, session[:user_id]]
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
  @posts = db.execute(
    "SELECT posts.*, users.username 
    FROM posts 
    JOIN users ON posts.user_id = users.id 
    WHERE posts.id = ?",
    [id]
  ).first
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

post('/:id/update') do
  if session[:user_id]
    db = SQLite3::Database.new("db/posts.db")
    id = params[:id].to_i
    db.results_as_hash = true
    post = db.execute("SELECT * FROM posts WHERE id = ?", [id]).first

    if post && post["user_id"] == session[:user_id]
      title = params[:title]
      description = params[:description]
      price = params[:price].to_f
      price_type = params[:price_type]

      if params[:image] && params[:image][:tempfile] && params[:image][:filename]
        tempfile = params[:image][:tempfile]

        filename = params[:image][:filename]
        filename = filename.force_encoding("UTF-8")
        filename = filename.gsub(/[^0-9A-Za-z.\-]/, "_")

        save_path = "./public/img/#{filename}"

        File.open(save_path, "wb") do |f|
          f.write(tempfile.read)
        end

        image_url = "/img/#{filename}"
      else
        image_url = post["image_url"]
      end

      db.execute(
        "UPDATE posts SET title = ?, description = ?, price_type = ?, price = ?, image_url = ? WHERE id = ?",
        [title, description, price_type, price, image_url, id]
      )
    end
  end

  redirect('/myads')
end

get('/:id/update') do
  redirect('/login') unless session[:user_id]

  db = SQLite3::Database.new("db/posts.db")
  db.results_as_hash = true

  id = params[:id].to_i
  @posts = db.execute("SELECT * FROM posts WHERE id = ?", [id]).first

  if @posts && @posts["user_id"] == session[:user_id]
    slim(:update)
  else
    redirect('/myads')
  end
end