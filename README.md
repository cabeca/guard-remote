# Guard::Remote

A simple Guard plugin to update remote directory via SFTP. Heavily inspired by [guard-flopbox](https://github.com/vincentchu/guard-flopbox). 
This gem is **experimental**. It works for me but it may eat all your data, as it has file deletion logic that isn't much tested. You have been warned.

## Features
 - Uploads created and updated files including directories
 - Removes deleted files including deleted directories

## TODO
 - Remove mandatory username from configuration. Get the current username.
 - Handle disconnections and network problems gracefully
 - Implement some kind of exclude list (`git ls-files` maybe?)

## Installation

Add this line to your application's Gemfile:

    gem 'guard-remote', github: 'cabeca/guard-remote'

And then execute:

    $ bundle

This gem isn't available in rubygems yet.

## Usage

In the directory you want to remote update, install the Guard Remote configuration snippet in Guardfile:

    guard init remote

Then edit Guardfile to suit your needs. Here is the example snippet added:

```ruby
  # Configuration Options for guard-remote
  opts = {
    :hostname  => "example.com",         # remote host 
    :user      => "username",            # remote user
    :sftp_opts => {},                    # options passed to Net::SFTP
    :remote    => "test",                # remote directory
    :debug     => true,                  # output debug information
  }

  group 'remote' do
    guard 'remote', opts do
      watch(/.*/)
    end
  end
```
You need to have ssh public key login enabled for the specified hostname.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
