Pod::Spec.new do |s|
  s.name         = 'FWWebView'
  s.version      = '1.0.9'
  s.summary      = 'UIWevview Update Class.'
  s.description  = <<-DESC
                   this class is UIWebview native and html connection support.
                   DESC

  s.authors      = {'ateliee' => 'info@ateliee.com'}
  s.homepage     = 'https://github.com/ateliee/FWWebView'
  s.license      = { :type => 'License, Version 1.0', :text => <<-LICENSE
    Licensed under the License, Version 1.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    https://github.com/ateliee/FWWebView/blob/master/LICENSE

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.platform     = :ios, '5.0'
  s.source       = { :git => 'https://github.com/ateliee/FWWebView.git', :tag => '1.0.9' }
  s.source_files  = 'Classes', '*.{h,m}'
  s.requires_arc  = true
  s.dependencies = { 'IOSHelper' => '>= 1.0.1' } 
end
