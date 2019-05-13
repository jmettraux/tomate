
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
      text = argv.join(' ')

      write_start(t, text)

      notify('pomodoro started', sound: 'submarine')

      sleep(WORK_DURATION)

      write_end(t, text)

      notify('pomodoro ended', sound: 'default')

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

    def notify(text, opts={})

      opts[:title] = TITLE

      if defined?(TerminalNotifier)
        TerminalNotifier.notify(text, opts)
      else
fail
      end
    end
  end
end


com = ARGV.shift || 'query'
Tomate.send(com, ARGV)

