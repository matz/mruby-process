# MIT License
#
# Copyright (c) 2017 Sebastian Katzer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require "#{MRUBY_ROOT}/lib/mruby/source"

def target_win32?
  return true if RUBY_PLATFORM =~ /mingw|mswin/
  build.is_a?(MRuby::CrossBuild) && build.host_target.to_s =~ /mingw/
end

MRuby::Gem::Specification.new('mruby-process') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Sebastián Katzer, appPlant GmbH'

  spec.add_test_dependency 'mruby-print', core: 'mruby-print'
  spec.add_test_dependency 'mruby-env',   mgem: 'mruby-env'
  spec.add_test_dependency 'mruby-os',    mgem: 'mruby-os'

  if MRuby::Source::MRUBY_VERSION >= '1.4.0'
    spec.add_test_dependency 'mruby-io',  core: 'mruby-io'
  else
    spec.add_test_dependency 'mruby-io',  mgem: 'mruby-io'
  end

  spec.mruby.cc.defines << 'HAVE_MRB_PROCESS_H'

  [spec.cc, spec.mruby.cc].each do |cc|
    cc.include_paths << "#{spec.dir}/include/mruby/ext"
  end

  if build.test_enabled?
    ENV['RAND'] = Time.now.to_i.to_s
    FileUtils.mkdir_p("#{MRUBY_ROOT}/../tmp")
  end

  if target_win32?
    spec.objs.delete objfile("#{build_dir}/src/posix")
  else
    spec.objs.delete objfile("#{build_dir}/src/win32")
  end
end
