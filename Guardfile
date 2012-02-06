# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'shell' do
	watch(%r{^src/.+\.as}) { |m| 
		compile
	}

	watch(%r{^test/.+Test(Suite|Runner)?\.(as|mxml)}) { |m| 
		compile
	}
end

def compile
	compiled = system('mxmlc -debug=true -output=bin/StutterTestRunner.swf -library-path+=./libs/ -source-path+=test/ -source-path+=src/ -static-link-runtime-shared-libraries=true test/StutterTestRunner.mxml')
	system('open bin/StutterTestRunner.swf') if compiled
end