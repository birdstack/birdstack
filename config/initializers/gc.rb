if !ENV['RUBY_GC_STATS'].nil? and ENV['RUBY_GC_STATS'] == '1' then
  GC.enable_stats
end
