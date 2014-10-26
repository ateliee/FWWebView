Pod::Spec.new do |s|
  s.name         = 'FWWebView'
  s.version      = '1.0.0'
  s.summary      = 'UIWevview Update Class.'
  s.description  = <<-DESC
                   this class is UIWebview native and html connection support.
                   DESC

  s.authors      = {'ateliee' => 'info@ateliee.com'}
  s.homepage     = 'https://github.com/ateliee/FWWebView'
  s.license      = 'MIT'
  s.platform     = :ios
  s.source       = { :git => 'git@github.com:ateliee/FWWebView.git', :tag => '1.0.0' }
  s.source_files  = 'Classes', '*.{h,m}'
  s.requires_arc  = true
end
