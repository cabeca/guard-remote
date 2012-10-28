require 'guard'
require 'guard/guard'
require 'net/sftp'

module Guard
  class Remote < Guard
    VERSION = "0.0.1"

    attr_reader :sftp_session, :remote, :pwd

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      @sftp_session = Net::SFTP.start(options[:hostname], options[:user], options[:sftp_opts])
      @remote       = options[:remote]
      @debug        = options[:debug]
      @pwd          = Dir.pwd
      
      log "Initialized with watchers = #{watchers.inspect}"
      log "Initialized with options  = #{options.inspect}"
      super
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_changes(paths)
      paths.each do |path|
        local_file  = File.join(pwd, path)
        remote_file = File.join(remote, path)
        
        attempts = 0
        begin
          log "Upload #{local_file} => #{remote_file}"
          sftp_session.upload!(local_file, remote_file)
        rescue Net::SFTP::StatusException => ex
          log "Exception on upload #{path} - directory likely doesn't exist"

          attempts += 1
          remote_dir = File.dirname(remote_file)
          recursively_create_dirs( remote_dir )          

          retry if (attempts < 3)
          log "Exceeded 3 attempts to upload #{path}"
          notify("Did NOT upload #{path}", :failed)
        end
      end
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_removals(paths)
      paths.each do |path|
        local_file  = File.join(pwd, path)
        remote_file = File.join(remote, path)
        
        attempts = 0
        begin
          log "Remove #{local_file} => #{remote_file}"
          # remove remote file
          sftp_session.remove!(remote_file)

          remote_dir = File.dirname(remote_file)
          local_dir = File.dirname(local_file)
          recursively_remove_dirs(local_dir,remote_dir)

        rescue Net::SFTP::StatusException => ex
          log "Exception on remove #{path} - retrying"

          attempts += 1
          retry if (attempts < 3)
          log "Exceeded 3 attempts to remove #{path}"
          notify("Did NOT remove #{path}", :failed)
        end
      end
    end

  private

    def debug?
      @debug || false
    end

    def log(mesg)
      return unless debug?

      puts "[#{Time.now}] #{mesg}"
    end

    def notify(msg, image=nil)
      Notifier.notify(msg, :title => 'Guard Remote', :image => image)
    end


    def recursively_create_dirs(remote_dir)
      new_dir = remote
      remote_dir.gsub(remote, "").split("/").each do |dir|
        
        new_dir = File.join(new_dir, dir)
        
        begin
          log "Creating #{new_dir}"
          sftp_session.mkdir!(new_dir)
        rescue Net::SFTP::StatusException => ex
        end
      end
    end

    def recursively_remove_dirs(local_dir, remote_dir)
      # see if local dir exists. 
      # If it doesn't, try to remove remote dir.
      # This may fail if the remote dir is not empty
      # This is ok as there may be more file deletions comming in the pipe
      return if File.directory?(local_dir)
      begin
        log "Removing directory #{remote_dir}"
        sftp_session.rmdir!(remote_dir)
        recursively_remove_dirs( File.dirname(local_dir), File.dirname(remote_dir) )
      rescue Net::SFTP::StatusException => ex
        log "Exception on remove directory #{remote_dir} - Probably not empty, skipping."
        return
      end

    end

  end
end