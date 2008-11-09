module CoreExt
  module ToSelectionList
    def to_selection_list
      map {|obj| [obj, obj.id]}
    end
  end
end

Array.send :include, CoreExt::ToSelectionList
