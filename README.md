
Project to reproduce a problem with XCRemoteCache when a Hybrid target doesn't call Objective-C compilation when a fallback to a local compilation is happening.

#### Steps to reproduce

Call `./reproduce.sh` and see if the last build (which builds it locally) compiles ObjC - has some `CompileC` steps

#### Expected behaviour

There it/are `CompileC` output on a console