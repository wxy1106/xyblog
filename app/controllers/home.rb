# encoding: utf-8

RobbinSite.controllers do

  before :login, :weibo_login do
    redirect url(:index) if account_login?
  end
  
  get :index do
    @blogs = Blog.order('id DESC').page(params[:page])
    render 'home/index'
  end

  #性能限制暂时不能使用elasticsearch
  get :search do
    blog_ids = []
    if APP_CONFIG["blog_search"]
      client = Elasticsearch::Client.new log: true
      Blog.all.each do |blog|
        client.index index: 'xyblog', type: 'article', id: blog.id, body: {title: blog.title, content: blog.content}
      end
      raw_result = client.search index: 'xyblog', body: { query: { match: { _all: params[:q] } } }
      blog_ids = []
      raw_result['hits']['hits'].each do |search_id|
        blog_ids << search_id['_id'].to_i
      end
    end
    @blogs = Blog.find(blog_ids)
    render 'home/search'
  end
  
  get :weibo do
    render 'home/weibo'
  end
  
  get :rss do
    content_type :rss
    @blogs = Blog.order('id DESC').limit(20)
    render 'home/rss'
  end

  # native authentication
  get :login, :map => '/login' do
    @account = Account.new
    render 'home/login'
  end
  
  post :login, :map => '/login' do
    login_tries = APP_CACHE.read("#{CACHE_PREFIX}/login_counter/#{request.ip}")
    halt 403 if login_tries && login_tries.to_i > 5  # reject ip if login tries is over 5 times
    @account = Account.new(params[:account])
    if login_account = Account.authenticate(@account.email, @account.password)
      session[:account_id] = login_account.id
      response.set_cookie('user', {:value => login_account.encrypt_cookie_value, :path => "/", :expires => 2.weeks.since, :httponly => true}) if params[:remember_me]
      flash[:notice] = '成功登录'
      redirect url(:index)
    else
      # retry 5 times per one hour
      APP_CACHE.increment("#{CACHE_PREFIX}/login_counter/#{request.ip}", 1, :expires_in => 1.hour)
      render 'home/login'
    end
  end

  delete :logout, :map => '/logout' do
    if account_login?
      session[:account_id] = nil
      response.delete_cookie("user")
      flash[:notice] = "成功退出"
    end
    redirect url(:index)
  end

  # weibo authentication
  get :weibo_login do
    session[:quick_login] = true if params[:quick_login]
    redirect WeiboAuth.new.authorize_url
  end

  get :weibo_callback do
    halt 401, "没有微博验证码" unless params[:code]
    auth = WeiboAuth.new
    begin
      auth.callback(params[:code])
      user_info = auth.get_user_info
      @account = Account.where(:provider => 'weibo', :uid => user_info['id'].to_i).first
      # create commenter account when first weibo login
      unless @account 
        @account = Account.create(:provider => 'weibo', :uid => user_info['id'], :name => user_info['screen_name'], :role => 'commenter', :profile_url => user_info['profile_url'], :profile_image_url => user_info['profile_image_url'])
      end
      # update weibo profile if profile is empty
      if @account.profile_url.blank? || @account.profile_image_url.blank?
        @account.update_attributes(:profile_url => user_info['profile_url'], :profile_image_url => user_info['profile_image_url'])
      end
      session[:account_id] = @account.id
      if session[:quick_login]
        session[:quick_login] = nil
        render 'home/weibo_callback', :layout => false
      else
        flash[:notice] = '成功登录'
        redirect_to url(:index)
      end
    rescue => e
      STDERR.puts e
      STDERR.puts e.backtrace.join("\n")
      halt 401, "授权失败，请重试几次"
    end
  end
end