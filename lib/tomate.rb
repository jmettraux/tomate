
require 'time'
require 'terminal-notifier' rescue nil


module Tomate

  VERSION = '1.0.0'
  TITLE = 'tomate ' + VERSION

  FILEPATH = File.join(ENV['HOME'], 'tomate.txt')
  WORK_DURATION = 25 * 60
  BREAK_DURATION = 5 * 60

  class << self

    def start(args)

      t = Time.now
      text = args.join(' ')

      write_start(t, text)

      notify('pomodoro started', sound: 'submarine')

      sleep(WORK_DURATION)

      write_end(t, text)

      notify('pomodoro ended', sound: 'default')

      sleep(BREAK_DURATION)

      notify("pomodoro 5' break ended", sound: 'morse')
    end

    def query

      lin = File.readlines(FILEPATH).last
      sta = Time.parse(lin.split(' - ').first)
      edn = sta + WORK_DURATION
      now = Time.now

      if now < edn
        dlt = (edn - now).to_i / 60
        puts "current pomodoro ends in #{dlt}m at #{edn}"
        puts "> #{lin.strip}"
      else
        puts "no pomodoro currently"
      end
    end

    protected

    def write_start(time, text)

      sta = time.strftime('%F %R')

      File.open(FILEPATH, 'ab') { |f| f.puts("#{sta} -   :    #{text}") }
    end

    def write_end(time, text)

      sta = time.strftime('%F %R')
      edn = (time + WORK_DURATION).strftime('%R')

      lines = File.readlines(FILEPATH)
      line = lines.pop

      if line == "#{sta} -   :    #{text}\n"
        File.open(FILEPATH, 'wb') { |f| lines.each { |l| f.write(l) } }
      end

      File.open(FILEPATH, 'ab') { |f| f.puts("#{sta} - #{edn}  #{text}") }
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


if ARGV.any?
  Tomate.start(ARGV)
else
  Tomate.query
end

