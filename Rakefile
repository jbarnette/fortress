desc "Add a new repo."
task :add, [:repo, :name] => %w(env add:before)

desc "Start over."
task :clean do
  File.read(".gitignore").split("\n").each { |f| rm_rf f }
end

desc "Remove a repo."
task :rm, [:name] => %w(env rm:before)

task :default do
  puts "Hi! Read the README."
end

# No public tasks below here. If you're not using Passenger (or basic
# auth or whatever) you're probably going to want to start hacking
# somewhere around the :env and :templates tasks.

task "add:before", [:repo, :name] do |_, args|
  repo  = args.repo || abort("Need repo!")
  name  = args.name || File.basename(repo, ".git")
  tasks = Rake::Task[:add].prerequisites
  dir   = "projects/#{name}"

  directory a("#{dir}/public")

  file a("#{dir}/repo/.git") do |t|
    mkdir_p dest = File.dirname(t.name)
    sh "git clone #{repo} #{dest}"
  end

  file a("#{dir}/config.ru") do |t|
    ln_s File.expand_path("config/config.ru"), t.name
  end

  file a("public/#{name}") do |t|
    ln_s File.expand_path("#{dir}/public"), t.name
  end

  %w(build-failed build-worked runner).each do |hook|
    file a("#{dir}/repo/.git/hooks/#{hook}") do |t|
      ln_s File.expand_path("config/hooks/#{hook}"), t.name
    end
  end

  task a(:config) do
    Dir.chdir "#{dir}/repo" do
      sh "git config --add cijoe.runner '.git/hooks/runner'"
    end
  end

  a :templates
end

task "rm:before", [:name] => :env do |_, args|
  name = args.name || abort("Need name!")
  %W(projects/#{name} public/#{name}).each { |n| rm_rf n }
  Rake::Task[:rm].prerequisites << :templates
end

task :env => %w(config/htpasswd projects public)

task :templates do
  require "erb"

  @htpasswd = File.expand_path "config/htpasswd"
  @projects = Dir["projects/*"].map { |d| File.basename d }
  @public   = File.expand_path "public"

  r "config/templates/apache.conf.erb", "config/apache.conf"
  r "config/templates/index.html.erb",  "public/index.html"
end

directory "projects"

file "public" do
  mkdir "public"

  Dir["vendor/cijoe/lib/cijoe/public/*"].each do |f|
    ln_s File.expand_path(f), "public/#{File.basename f}"
  end
end

file "config/htpasswd" do |t|
  puts "Creating #{t.name} entry for #{ENV['USER']}."
  sh "htpasswd -c config/htpasswd #{ENV['USER']}"
end

def a *t; Rake::Task[:add].prerequisites.concat t; t.first end
def r s, t; File.open(t,"wb"){|f|f<< ERB.new(File.read(s)).result} end
