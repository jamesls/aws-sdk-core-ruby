task 'release_notes:html' do

  require 'erb'
  require 'rdiscount'

  labels = {
    'Upgrading' => 'Upgrading Notes',
    'Feature' => 'New Features',
    'Issue' => 'Resolved Issues',
  }

  categories = {
    'Upgrading Notes' => [],
    'New Features' => [],
    'Resolved Issues' => [],
  }

  entries = []
  `rake changelog:latest`.lines.map(&:strip).each do |line|
    if line.match(/^\*/)
      entries << line.sub(/\* /, '')
    else
      entries.last.concat(' ' + line)
    end
  end

  entries.each do |entry|
    label, changed, description = entry.split(' - ')
    changed = changed.gsub('`', '')
    description = RDiscount.new(description).to_html
    categories[labels[label]] << [changed, description]
  end

  services = {}
  Aws.services.each do |_, svc_module, _|
    client_class = svc_module.const_get(:Client)
    name = client_class.api.metadata('serviceFullName')
    services[name] = client_class.api.version
  end

  services = services.keys.sort_by(&:downcase).inject({}) do |h,k|
    h[k] = services[k]
    h
  end

  template = File.read('tasks/release-notes-template.html.erb')
  puts ERB.new(template, false, '<>').result(binding)

end
