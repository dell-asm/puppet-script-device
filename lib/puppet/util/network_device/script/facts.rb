require 'puppet/util/network_device/script'
require 'cgi'
require 'json'
require '/etc/puppetlabs/puppet/modules/asm_lib/lib/security/encode'

class Puppet::Util::NetworkDevice::Script::Facts
  def initialize(url)
    @url = url
  end

  def path_to_script(script)
    Puppet.settings[:modulepath].split(":").each do |dir|
      file = File.join(dir, script)
      return file if File.exist?(file) && File.executable?(file)
    end

    raise("Could not find the script %s in %s, make sure it exists and is executable" % [script, Puppet.settings[:modulepath]])
  end

  def command_for_url
    args = []
    args << "--username='%s'" % URI.decode(@url.user) if @url.user
    args << "--password='%s'" % URI.decode(asm_decrypt(@url.password)) if @url.user
    args << "--port=%s" % @url.port if @url.port
    args << "--server=%s" % @url.host if @url.host

    if @url.query
      CGI.parse(@url.query).each do |k, v|
        args << "--%s='%s'" % [URI.decode(k).gsub('_','-'), URI.decode(v.first)]
      end
    end

    cmd = path_to_script(@url.path[1..-1])

    "%s %s" % [cmd, args.join(" ")]
  end

  def retrieve
    facts = {"device_type" => "script"}
    facts["certname"] = @url.host if @url.host

    script_facts = (JSON.parse(Puppet::Util::Execution.execute(command_for_url)).merge({"certname" => @url.host}))

    # until we are on new puppetdb if we detect we are getting structured data store
    # the data as a JSON encoded string into the 'json_facts' fact
    if script_facts.reject {|k,v| [Fixnum, String].include?(v.class)}.empty?
      facts.merge!(script_facts)
    else
      facts.merge!({"json_facts" => JSON.dump(script_facts)})
    end

    facts
  end
end
