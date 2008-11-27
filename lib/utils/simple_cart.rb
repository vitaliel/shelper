#
# Author: Vitalie Lazu
# Date: Sun, 23 Nov 2008 19:02:59 +0200
#

module Utils; end

# Simple Cart to hold objects and to process them in one batch
class Utils::SimpleCart

  # max_items - how many items to hold in cart before passing them to batch processing
  # process_proc - method to pass batch items
  def initialize(max_items, process_proc, &block)
    @max_items = max_items
    @items = []
    @process_proc = process_proc

    begin
      yield self
    ensure
      process
    end
  end

  def add_item(item)
    if @items.size > @max_items
      process
    end

    @items << item
  end

  def process
    return if @items.size == 0

    @process_proc.call(@items)
    @items = []
  end
end
