
require 'time'
require 'terminal-notifier' rescue nil


module Tomate

  VERSION = '1.0.0'
  TITLE = 'tomate ' + VERSION

  FILEPATH = File.join(ENV['HOME'], 'tomate.txt')
  WORK_DURATION = 25 * 60
  BREAK_DURATION = 5 * 60

  class << self

    def start(argv)

      t = Time.now

      text =
        if argv.any?
          argv.join(' ')
        else
          last_text
        end

      write_start(t, text)

      notify(text, 'pomodoro started', sound: 'submarine')

      sleep(WORK_DURATION)

      write_end(t, text)

      notify(text, 'pomodoro ended', sound: 'default')

      sleep(BREAK_DURATION)

      notify("pomodoro 5' break ended", sound: 'morse')
    end
    alias s start

    def query(argv)

      sta, edn, dlt, pid, lin = current_line

      if sta
        puts "current pomodoro (#{pid}) ends in #{dlt}m at #{edn}"
        puts "> #{lin.split('-').last}"
      else
        puts "no pomodoro currently"
      end
    end
    alias q query

    def today(argv)

      tod = Time.now.strftime('%F')

      File.readlines(FILEPATH).each do |l|
        print(l) if l[0, 10] == tod
      end
    end
    alias to today

    def kill(argv)

      sta, edn, dlt, pid, lin = current_line

      if sta
        puts "current pomodoro (#{pid}) should end in #{dlt}m at #{edn}"
        if system("kill -9 #{pid}")
          puts "killed."
        end
      else
        puts "no pomodoro currently"
      end
    end
    alias k kill

    def all(argv)

      print(File.read(FILEPATH))
    end
    alias a all

    protected

    def current_line

      lin = (File.readlines(FILEPATH) rescue []).last

      return nil unless lin

      sta, _, pid = lin.split(' - ')
      sta = Time.parse(sta)
      edn = sta + WORK_DURATION
      now = Time.now

      if Time.now < edn
        [ sta, edn, (edn - now).to_i / 60, pid, lin ]
      else
        nil
      end
    end

    def last_text

      lin = (File.readlines(FILEPATH) rescue []).last

      fail "no previous line" unless lin

      lin.split('-')[5..-1].join('-').strip
    end

    def write_start(time, text)

      sta = time.strftime('%F %R')
      pid = Process.pid

      File.open(FILEPATH, 'ab') do |f|
        f.puts("#{sta} -   :   - #{pid} - #{text}")
      end
    end

    def write_end(time, text)

      sta = time.strftime('%F %R')
      edn = (time + WORK_DURATION).strftime('%R')
      pid = Process.pid

      lines = File.readlines(FILEPATH)
      line = lines.pop

      if line == "#{sta} -   :   - #{pid} - #{text}\n"
        File.open(FILEPATH, 'wb') { |f| lines.each { |l| f.write(l) } }
      end

      File.open(FILEPATH, 'ab') do |f|
        f.puts("#{sta} - #{edn} - #{pid} - #{text}")
      end
    end

    def notify(text0, text1=nil, opts=nil)

      text1, opts =
        if text1.is_a?(Hash)
          [ nil, text1 ]
        else
          [ text1, opts || {} ]
        end
      subtitle, message =
        if text1
          [ text0, text1 ]
        else
          [ nil, text0 ]
        end

      opts[:title] = TITLE
      opts[:subtitle] = subtitle if subtitle

      if defined?(TerminalNotifier)
        TerminalNotifier.notify(message, opts)
      else
fail
      end
    end
  end
end


com = ARGV.shift || 'query'
Tomate.send(com, ARGV)

