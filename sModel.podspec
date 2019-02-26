Pod::Spec.new do |s|
  s.name         = "sModel"
  s.version      = "1.0.15"
  s.summary      = "sModel is a lightweight Swift ORM backed by sqlite."

  s.description  = <<-DESC
  sModel is a Swift framework written on top of FMDB to provide:
    - Simple management of your database schema (including schema updates)
    - Simple mapping of database rows to Swift objects
    - Batch updates for improved performance on large updates
    - Simplified handling of local data that gets synchronized with external data

  The sModel library has been used for many years on multiple apps found in the AppStore.  This code is production ready and  has been battle tested by millions of
  users across multiple apps. Compatible with Swift 4.
                   DESC

  s.homepage     = "https://github.com/FamilySearch/sModel"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author       = { "Stephen Lynn" => "slynn@familysearch.org" }

  s.swift_version = "4.0"
  s.ios.deployment_target		= "9.0"
  s.source       = { :git => "https://github.com/FamilySearch/sModel.git", :tag => "v#{s.version.to_s}" }
  s.source_files  = "Sources/*.swift"
  s.requires_arc  = true
  s.module_name  = "sModel"

  s.dependency "FMDB", "2.7.5"
end
