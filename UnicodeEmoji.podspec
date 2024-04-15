Pod::Spec.new do |s|
  s.name             = 'UnicodeEmoji'
  s.version          = '1.3.0'
  s.summary          = 'Use official Unicode Emoji versions for your app.'

  s.description      = 'Use official Unicode Emoji versions for your app.
  Detect the right Emoji version to use depending on the iOS version.
  Organizes the emojis in their respective categories.'

  s.homepage         = 'https://github.com/rootstrap/UnicodeEmoji'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rootstrap' => 'german@rootstrap.com' }
  s.source           = { :git => 'https://github.com/rootstrap/UnicodeEmoji.git',
                         :tag => s.version.to_s
                       }
  s.social_media_url = 'https://www.rootstrap.com'
  
  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*'
  s.frameworks = 'UIKit'
  s.swift_version = '5.2'
end
