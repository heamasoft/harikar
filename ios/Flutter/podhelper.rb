# Copyright 2014 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
require 'json'

# Minimum CocoaPods Ruby version is 2.0. Don't depend on features newer than that.

# Hook for Podfile setup, installation settings.
#
# @example
# flutter_ios_podfile_setup
# target 'Runner' do
#   ...
# end
def flutter_ios_podfile_setup; end
# Same as flutter_ios_podfile_setup for macOS.
def flutter_macos_podfile_setup; end

# Determine whether the target depends on Flutter (including transitive dependency)
def depends_on_flutter(target, engine_pod_name)
  target.dependencies.any? do |dependency|
    if dependency.name == engine_pod_name
      return true
    end
    if depends_on_flutter(dependency.target, engine_pod_name)
      return true
    end
  end
  return false
end

# Add iOS build settings to pod targets.
#
# @example
# post_install do |installer|
#   installer.pods_project.targets.each do |target|
#     flutter_additional_ios_build_settings(target)
#   end
# end
#
# @param [PBXAggregateTarget] target Pod target.
def flutter_additional_ios_build_settings(target)
  return unless target.platform_name == :ios
  # [target.deployment_target] is a [String] formatted as "8.0".
  inherit_deployment_target = target.deployment_target[/\d+/].to_i < 13
  force_to_arc_supported_min = target.deployment_target[/\d+/].to_i < 9

  # This podhelper script is at $FLUTTER_ROOT/packages/flutter_tools/bin.
  # Add search paths from $FLUTTER_ROOT/bin/cache/artifacts/engine.
  artifacts_dir = File.join('..', '..', '..', '..', 'bin', 'cache', 'artifacts', 'engine')
  debug_framework_dir = File.expand_path(File.join(artifacts_dir, 'ios', 'Flutter.xcframework'), __FILE__)
  unless Dir.exist?(debug_framework_dir)
    raise "#{debug_framework_dir} must exist. If you're running pod install manually, make sure \"flutter precache --ios\" is executed first"
  end
  release_framework_dir = File.expand_path(File.join(artifacts_dir, 'ios-release', 'Flutter.xcframework'), __FILE__)

  target_is_resource_bundle = target.respond_to?(:product_type) &&
                              target.product_type == 'com.apple.product-type.bundle'
  target.build_configurations.each do |build_configuration|
    # Build both x86_64 and arm64 simulator archs for all dependencies.
    build_configuration.build_settings['ONLY_ACTIVE_ARCH'] = 'NO' if build_configuration.type == :debug

    # Do not sign resource bundles.
    if target_is_resource_bundle
      build_configuration.build_settings['CODE_SIGNING_ALLOWED']  = 'NO'
      build_configuration.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      build_configuration.build_settings['CODE_SIGNING_IDENTITY'] = '-'
      build_configuration.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = '-'
    end

    # ARC code targeting iOS 8 does not build on Xcode 14.3. Force to at least iOS 9.
    build_configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0' if force_to_arc_supported_min

    # Skip other updates if it does not depend on Flutter.
    next unless depends_on_flutter(target, 'Flutter')

    build_configuration.build_settings['ENABLE_BITCODE'] = 'NO'
    configuration_engine_dir = build_configuration.type == :debug ? debug_framework_dir : release_framework_dir
    Dir.new(configuration_engine_dir).each_child do |xcframework_file|
      next if xcframework_file.start_with?('.')
      if xcframework_file.end_with?('-simulator')
        build_configuration.build_settings['FRAMEWORK_SEARCH_PATHS[sdk=iphonesimulator*]'] =
          "\"#{configuration_engine_dir}/#{xcframework_file}\" $(inherited)"
      elsif xcframework_file.start_with?('ios-')
        build_configuration.build_settings['FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]'] =
          "\"#{configuration_engine_dir}/#{xcframework_file}\" $(inherited)"
      end
    end

    build_configuration.build_settings['OTHER_LDFLAGS'] = '$(inherited) -framework Flutter'
    build_configuration.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'

    # Suppress warning when pod supports a version lower than the minimum supported by Xcode.
    build_configuration.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET' if inherit_deployment_target

    # Override legacy Xcode 11 style VALID_ARCHS and EXCLUDED_ARCHS.
    build_configuration.build_settings['VALID_ARCHS[sdk=iphonesimulator*]'] = '$(ARCHS_STANDARD)'
    build_configuration.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = '$(inherited) i386'
    build_configuration.build_settings['EXCLUDED_ARCHS[sdk=iphoneos*]']       = '$(inherited) armv7'
  end
end

# Same as flutter_additional_ios_build_settings for macOS.
def flutter_additional_macos_build_settings(target)
  return unless target.platform_name == :osx
  # ARC code targeting macOS 10.10 does not build on Xcode 14.3.
  deployment_target_major, deployment_target_minor =
    target.deployment_target.match(/(\d+).?(\d*)/).captures
  force_to_arc_supported_min =
    !target.deployment_target.blank? &&
    (deployment_target_major.to_i < 10 ||
     (deployment_target_major.to_i == 10 && deployment_target_minor.to_i < 11))
  inherit_deployment_target =
    !target.deployment_target.blank? &&
    (deployment_target_major.to_i < 10 ||
     (deployment_target_major.to_i == 10 && deployment_target_minor.to_i < 15))

  artifacts_dir = File.join('..', '..', '..', '..', 'bin', 'cache', 'artifacts', 'engine')
  debug_framework_dir   = File.expand_path(File.join(artifacts_dir, 'darwin-x64',         'FlutterMacOS.xcframework'), __FILE__)
  release_framework_dir = File.expand_path(File.join(artifacts_dir, 'darwin-x64-release', 'FlutterMacOS.xcframework'), __FILE__)
  application_path      = File.dirname(defined_in_file.realpath) if respond_to?(:defined_in_file)
  if !Dir.exist?(debug_framework_dir)
    raise "#{debug_framework_dir} must exist. If you're running pod install manually, make sure \"flutter precache --macos\" is executed first"
  end

  target.build_configurations.each do |build_configuration|
    build_configuration.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.11' if force_to_arc_supported_min
    next unless depends_on_flutter(target, 'FlutterMacOS')

    if application_path
      local_engine = flutter_get_local_engine_dir(File.join(application_path, 'Flutter', 'ephemeral', 'Flutter-Generated.xcconfig'))
    end
    configuration_engine_dir = local_engine || (build_configuration.type == :debug ? debug_framework_dir : release_framework_dir)

    Dir.new(configuration_engine_dir).each_child do |xcframework_file|
      if xcframework_file.start_with?('macos-')
        build_configuration.build_settings['FRAMEWORK_SEARCH_PATHS'] =
          "\"#{configuration_engine_dir}/#{xcframework_file}\" $(inherited)"
      end
    end

    build_configuration.build_settings.delete 'MACOSX_DEPLOYMENT_TARGET' if inherit_deployment_target
    build_configuration.build_settings.delete 'EXPANDED_CODE_SIGN_IDENTITY'
    build_configuration.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    build_configuration.build_settings['CODE_SIGNING_ALLOWED']  = 'NO'
  end
end

# Install pods needed to embed Flutter iOS engine and plugins.
#
# @example
# target 'Runner' do
#   flutter_install_all_ios_pods
# end
#
# @param [String] ios_application_path Path of the iOS directory of the Flutter app.
#   Optional, defaults to the Podfile directory.
def flutter_install_all_ios_pods(ios_application_path = nil)
  flutter_install_ios_engine_pod(ios_application_path)
  flutter_install_plugin_pods(ios_application_path, '.symlinks', 'ios')
end

# Same as flutter_install_all_ios_pods for macOS.
def flutter_install_all_macos_pods(macos_application_path = nil)
  flutter_install_macos_engine_pod(macos_application_path)
  flutter_install_plugin_pods(macos_application_path, File.join('Flutter', 'ephemeral', '.symlinks'), 'macos')
end

def flutter_install_ios_engine_pod(ios_application_path = nil)
  ios_application_path ||= File.dirname(defined_in_file.realpath) if respond_to?(:defined_in_file)
  raise 'Could not find iOS application path' unless ios_application_path
  podspec_directory = File.join(ios_application_path, 'Flutter')
  copied_podspec_path = File.expand_path('Flutter.podspec', podspec_directory)
  File.open(copied_podspec_path, 'w') do |podspec|
    podspec.write <<~EOF
      # This podspec is NOT to be published. It is only used as a local source!
      Pod::Spec.new do |s|
        s.name              = 'Flutter'
        s.version           = '1.0.0'
        s.summary           = 'A UI toolkit for beautiful and fast apps.'
        s.homepage          = 'https://flutter.dev'
        s.license           = { :type => 'BSD' }
        s.author            = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
        s.source            = { :git => 'https://github.com/flutter/engine', :tag => s.version.to_s }
        s.ios.deployment_target = '12.0'
        s.vendored_frameworks = 'path/to/nothing'
      end
    EOF
  end
  pod 'Flutter', path: flutter_relative_path_from_podfile(podspec_directory)
end

def flutter_install_macos_engine_pod(mac_application_path = nil)
  mac_application_path ||= File.dirname(defined_in_file.realpath) if respond_to?(:defined_in_file)
  raise 'Could not find macOS application path' unless mac_application_path
  copied_podspec_path = File.expand_path('FlutterMacOS.podspec', File.join(mac_application_path, 'Flutter', 'ephemeral'))
  File.open(copied_podspec_path, 'w') do |podspec|
    podspec.write <<~EOF
      # This podspec is NOT to be published. It is only used as a local source!
      Pod::Spec.new do |s|
        s.name                = 'FlutterMacOS'
        s.version             = '1.0.0'
        s.summary             = 'A UI toolkit for beautiful and fast apps.'
        s.homepage            = 'https://flutter.dev'
        s.license             = { :type => 'BSD' }
        s.author              = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
        s.source              = { :git => 'https://github.com/flutter/engine', :tag => s.version.to_s }
        s.osx.deployment_target = '10.14'
        s.vendored_frameworks   = 'path/to/nothing'
      end
    EOF
  end
  pod 'FlutterMacOS', path: File.join('Flutter', 'ephemeral')
end

def flutter_install_plugin_pods(application_path = nil, relative_symlink_dir, platform)
  application_path ||= File.dirname(defined_in_file.realpath) if respond_to?(:defined_in_file)
  raise 'Could not find application path' unless application_path

  symlink_dir         = File.expand_path(relative_symlink_dir, application_path)
  system('rm', '-rf', symlink_dir)
  symlink_plugins_dir = File.expand_path('plugins', symlink_dir)
  system('mkdir', '-p', symlink_plugins_dir)

  plugins_file       = File.join(application_path, '..', '.flutter-plugins-dependencies')
  dependencies_hash  = flutter_parse_plugins_file(plugins_file)
  plugin_pods        = flutter_get_plugins_list(dependencies_hash, platform)
  spm_enabled        = flutter_get_swift_package_manager_enabled(dependencies_hash, platform)

  plugin_pods.each do |plugin_hash|
    name         = plugin_hash['name']
    path         = plugin_hash['path']
    native_build = plugin_hash.fetch('native_build', true)
    shared_src   = plugin_hash.fetch('shared_darwin_source', false)
    dir          = shared_src ? 'darwin' : platform
    next unless name && path && native_build

    symlink = File.join(symlink_plugins_dir, name)
    File.symlink(path, symlink)
    relative = flutter_relative_path_from_podfile(symlink)

    swift_pkg = File.exist?(File.join(relative, dir, "#{name}/Package.swift"))
    next if spm_enabled && swift_pkg
    next if swift_pkg && !File.exist?(File.join(relative, dir, "#{name}.podspec"))

    pod name, path: File.join(relative, dir)
  end
end

def flutter_parse_plugins_file(file)
  path = File.expand_path(file)
  return [] unless File.exist?(path)
  JSON.parse(File.read(path))
end

def flutter_get_plugins_list(deps, platform)
  return [] unless deps.key?('plugins') && deps['plugins'].key?(platform)
  deps['plugins'][platform] || []
end

def flutter_get_swift_package_manager_enabled(deps, platform)
  deps.dig('swift_package_manager_enabled', platform) == true
end

def flutter_relative_path_from_podfile(path)
  project_dir = defined_in_file.dirname
  Pathname.new(File.expand_path(path))
          .relative_path_from(project_dir)
          .to_s
end

def flutter_parse_xcconfig_file(file)
  abs = File.expand_path(file)
  return {} unless File.exist?(abs)
  entries = {}
  File.foreach(abs) do |line|
    next if line =~ /^\s*[#\/]/
    key, val = line.split('=', 2).map(&:strip)
    entries[key] = val if key && val
  end
  entries
end

def flutter_get_local_engine_dir(xcconfig_file)
  abs = File.expand_path(xcconfig_file)
  return nil unless File.exist?(abs)
  config = flutter_parse_xcconfig_file(xcconfig_file)
  engine = config['LOCAL_ENGINE']
  base   = config['FLUTTER_ENGINE']
  engine && base && File.join(base, 'out', engine)
end
