$interrupted = false

Signal.trap("INT") {
  $interrupted = true
}

module Kernel
  def stfu
    result = nil
    begin
      orig_stderr = $stderr.clone
      orig_stdout = $stdout.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      result = yield
    rescue Exception => e
      if $interrupted
        throw :interrupted
      else
        $stdout.reopen orig_stdout
        $stderr.reopen orig_stderr
        raise e
      end
    ensure
      if $interrupted
        throw :interrupted
      else
        $stdout.reopen orig_stdout
        $stderr.reopen orig_stderr
      end
    end
    if $interrupted
      throw :interrupted
    else
      result
    end
  end

  def spawn_silenced_shell_process(shell_command)
    stfu do
      rout, wout = IO.pipe
      result = nil
      begin
        pid = Process.spawn(shell_command, out: wout)
        _, _ = Process.wait2(pid)
        wout.close
      ensure
        wout.close
        if $interrupted
          rout.close
          throw :interrupted
        else
          result = rout.readlines.join("\n")
          rout.close
        end
      end
      result
    end
  end
end
