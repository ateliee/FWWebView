Pod::Spec.new do |s|
  s.name         = 'FWWebView'
  s.version      = '1.0.0'
  s.summary      = 'UIWevview Update Class.'
  s.description  = <<-DESC
                   A longer description of FWWebView in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.authors      = {'ateliee' => 'info@ateliee.com'}
  s.homepage     = 'https://github.com/ateliee/FWWebView'
  s.license      = 'MIT'
  s.platform     = :ios
  s.source       = { :git => 'git@github.com:ateliee/FWWebView.git', :tag => '1.0.0' }
  s.source_files  = 'Classes', '*.{h,m}'
  s.requires_arc  = true
end
