#!/usr/bin/env ruby
#encoding: UTF-8

begin
  #读取配置文件
  require 'yaml'
  $config = YAML.load_file("config.yml") rescue {}
  $config['width'] ||= 1024
  $config['height'] ||= 768
  File.open("config.yml","w"){|config| YAML.dump($config, config)}
  
  #读取命令行参数
  log = "log.log"
  profile = nil
  ARGV.each do |arg|
    case arg
    when /--log=(.*)/
      log.replace $1
    when /--profile=(.*)/
      profile = $1
    end
  end

  #初始化SDL
  require 'sdl'
  include SDL
  SDL.init(INIT_VIDEO | INIT_AUDIO)
  WM::set_caption("MyCard", "graphics/system/icon.gif")
  WM::icon = Surface.load("graphics/system/icon.gif")
  $screen = Screen.open($config["width"], $config["height"], 0, HWSURFACE | ($config["fullscreen"] ? FULLSCREEN : 0))
  Mixer.open(Mixer::DEFAULT_FREQUENCY,Mixer::DEFAULT_FORMAT,Mixer::DEFAULT_CHANNELS,512)
  TTF.init
  
  #设置标准输出编码（windows)
  STDOUT.set_encoding "GBK", "UTF-8", :invalid => :replace, :undef => :replace if RUBY_PLATFORM["win"] || RUBY_PLATFORM["ming"]
  
  #初始化日志
  require 'logger'
  if log == "STDOUT" #调试用
    log = STDOUT
  end
  $log = Logger.new(log)
  $log.info("main"){"初始化成功"}
  
  #性能分析
  if profile
    if profile == "STDOUT"
      profile = STDOUT
    else
      profile = open(profile, 'w')
    end
    require 'profiler'
    RubyVM::InstructionSequence.compile_option = {
      :trace_instruction => true,
      :specialized_instruction => false
    }
    Profiler__::start_profile
  end
  
  #初始化标题场景
  require_relative 'scene_title'
  $scene = Scene_Title.new
rescue Exception => exception
  open('error-程序出错请到论坛反馈.txt', 'w'){|f|f.write [exception.inspect, *exception.backtrace].join("\n")}
  exit(1)
end

#主循环
begin
  $scene.main while $scene
rescue Exception => exception
  exception.backtrace.each{|backtrace|break if backtrace =~ /^(.*)\.rb:\d+:in `.*'"$/} #由于脚本是从main.rb开始执行的，总会有个能匹配成功的文件
  $log.fatal($1){[exception.inspect, *exception.backtrace].join("\n")}
  $game.exit if $game
  require_relative 'scene_error'
  $scene = Scene_Error.new
  retry
ensure
  if profile
    Profiler__::print_profile(profile)
    profile.close
  end
  $log.close
end