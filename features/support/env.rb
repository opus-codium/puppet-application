# frozen_string_literal: true

def workaround_async_ci
  # Linux seems to be able to group the creation of multiple files in a single
  # transaction that cause all of them to have the same ctime / mtime.
  #
  # Syncing is not enough because we can still see this on some CI systems,
  # this is suspected to be the consequence of some tuning.  Artificialy sleep
  # and sync to avoid this.
  sleep(0.1)
  `sync`
end

After do
  FileUtils.rm_r(@tmp_dir) if @tmp_dir
  @tmp_dir = nil
end
