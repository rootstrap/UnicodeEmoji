Pod::Spec.new do |s|
  s.name             = 'UnicodeEmoji'
  s.version          = '1.0.0'
  s.summary          = 'Summary'

  s.description      = 'Description'

  s.homepage         = 'https://github.com/rootstrap/UnicodeEmoji'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rootstrap' => 'your@email.com' }
  s.source           = { :git => 'https://github.com/rootstrap/UnicodeEmoji.git',
                         :tag => s.version.to_s
                       }
  s.social_media_url = ''
  
  s.ios.deployment_target = '9.3'

  s.source_files = 'Sources/**/*'
  s.frameworks = 'UIKit'
  s.swift_version = '5.2'
end
