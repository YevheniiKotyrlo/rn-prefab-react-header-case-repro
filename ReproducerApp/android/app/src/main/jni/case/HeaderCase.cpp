#include <react/renderer/components/view/ViewProps.h>
#include <React/View.h>

namespace facebook::react {

Float viewOpacity(const ViewProps& props) {
  return props.opacity;
}

} // namespace facebook::react
