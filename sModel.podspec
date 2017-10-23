Pod::Spec.new do |s|
  s.name         = "sModel"
  s.version      = "1.0.1"
  s.summary      = "sModel is a lightweight object mapper for sqlite."

  s.description  = <<-DESC
  sModel is a Swift framework written on top of FMDB to provides:
    - Simple management of your database schema (including database updates)
    - Simple mapping of database rows to Swift objects
    - Batch updates for improved performance on large updates
                   DESC

  s.homepage     = "https://github.com/FamilySearch/sModel"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "Stephen Lynn" => "slynn@familysearch.org" }

  s.ios.deployment_target		= "9.0"
  s.source       = { :git => "https://github.com/FamilySearch/sModel.git", :tag => "v#{s.version.to_s}" }
  s.source_files  = "Sources/*.swift"
  s.requires_arc  = true
  s.module_name  = "sModel"

  s.dependency "FMDB", "2.6"
end
