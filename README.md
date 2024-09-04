# reproduce-interference-between-librealsense2-and-mvviewer

This repository reproduces an issue on Ubuntu 22.04 involving interference between [librealsense2](https://github.com/IntelRealSense/librealsense) and [MVviewer-SDK](https://www.irayple.com/en/serviceSupport/downloadCenter/18?p=17) (specifically `Machine Vision MVviewer Client Ver2.3.2(Linux x86)`), causing unexpected behavior.

The main program is straightforward: it simply instantiates an `rs2::context` object from librealsense2, which should not cause any issues on its own. The source code for this program can be found in [`main.cpp`](https://github.com/sakurai-ryuhei/reproduce-interference-between-librealsense2-and-mvviewer/blob/5ae28aac2335a9a68df0a731d63eb844d82b1c3f/main.cpp).

However, when linked with `libMVSDK.so`, the constructor of `rs2::context` crashes. This crash is reproducible in a GitHub workflow. The workflow log can be found [here](https://github.com/sakurai-ryuhei/reproduce-interference-between-librealsense2-and-mvviewer/pull/1#issuecomment-2326178538).

The workflow script is located [here](https://github.com/sakurai-ryuhei/reproduce-interference-between-librealsense2-and-mvviewer/blob/5ae28aac2335a9a68df0a731d63eb844d82b1c3f/.github/workflows/workflow.yml). It installs the necessary libraries and then runs [`test.sh`](https://github.com/sakurai-ryuhei/reproduce-interference-between-librealsense2-and-mvviewer/blob/5ae28aac2335a9a68df0a731d63eb844d82b1c3f/test.sh), which first builds `main.cpp` and then executes the resulting binary, `main`.

To investigate the crash, we examined the stack trace, which can be found [here](https://github.com/sakurai-ryuhei/reproduce-interference-between-librealsense2-and-mvviewer/pull/3#issuecomment-2326175520). The stack trace reveals the following:
- At frame `#2`, `librealsense::platform::usb_context::usb_context()` attempts to call `libusb_get_device_list()`.
    - `libusb_get_device_list()` is a function provided by the `libusb` library.
- However, at frame `#1`, the program unexpectedly calls another `libusb_get_device_list()` function defined in the `libMVSDK` library.
- This may be the cause of the crash.

```
2024-09-03T10:30:27.0179557Z Stack trace (most recent call last):
2024-09-03T10:30:27.0345541Z #15   Object "", at 0xffffffffffffffff, in 
2024-09-03T10:30:27.0411525Z #14   Object "/home/runner/work/reproduce-interference-between-librealsense2-and-mvviewer/reproduce-interference-between-librealsense2-and-mvviewer/build/main", at 0x55964e8a7ee4, in _start
2024-09-03T10:30:27.0460429Z #13   Object "/usr/lib/x86_64-linux-gnu/libc.so.6", at 0x7f7aff429e3f, in __libc_start_main
2024-09-03T10:30:27.0463154Z #12   Object "/usr/lib/x86_64-linux-gnu/libc.so.6", at 0x7f7aff429d8f, in 
2024-09-03T10:30:27.0478281Z #11   Source "/home/runner/work/reproduce-interference-between-librealsense2-and-mvviewer/reproduce-interference-between-librealsense2-and-mvviewer/main.cpp", line 5, in main [0x55964e8a7fd4]
2024-09-03T10:30:27.0480923Z           3: int main()
2024-09-03T10:30:27.0481524Z           4: {
2024-09-03T10:30:27.0482072Z       >   5:     rs2::context ctx;
2024-09-03T10:30:27.0482762Z           6: }
2024-09-03T10:30:27.0493989Z #10   Source "/usr/include/librealsense2/hpp/rs_context.hpp", line 106, in context [0x55964e8a8934]
2024-09-03T10:30:27.0495558Z         103:         context( char const * json_settings = nullptr )
2024-09-03T10:30:27.0496650Z         104:         {
2024-09-03T10:30:27.0500830Z         105:             rs2_error* e = nullptr;
2024-09-03T10:30:27.0501839Z       > 106:             _context = std::shared_ptr<rs2_context>(
2024-09-03T10:30:27.0503181Z         107:                 rs2_create_context_ex( RS2_API_VERSION, json_settings, &e ),
2024-09-03T10:30:27.0506798Z         108:                 rs2_delete_context);
2024-09-03T10:30:27.0507737Z         109:             error::handle(e);
2024-09-03T10:30:27.0509365Z #9    Object "/usr/lib/x86_64-linux-gnu/librealsense2.so.2.55.1", at 0x7f7b008ed1a1, in rs2_create_context_ex
2024-09-03T10:30:27.0511601Z #8    Object "/usr/lib/x86_64-linux-gnu/librealsense2.so.2.55.1", at 0x7f7b008d4aeb, in librealsense::context::make(char const*)
2024-09-03T10:30:27.0516349Z #7    Object "/usr/lib/x86_64-linux-gnu/librealsense2.so.2.55.1", at 0x7f7b008d4a57, in librealsense::context::make(nlohmann::json_abi_v3_11_3::basic_json<std::map, std::vector, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, bool, long, unsigned long, double, std::allocator, nlohmann::json_abi_v3_11_3::adl_serializer, std::vector<unsigned char, std::allocator<unsigned char> >, rsutils::json_base> const&)
2024-09-03T10:30:27.0521246Z #6    Object "/usr/lib/x86_64-linux-gnu/librealsense2.so.2.55.1", at 0x7f7b008d4820, in librealsense::context::create_factories(std::shared_ptr<librealsense::context> const&)
2024-09-03T10:30:27.0526727Z #5    Object "/usr/lib/x86_64-linux-gnu/librealsense2.so.2.55.1", at 0x7f7b008cd4ec, in librealsense::backend_device_factory::backend_device_factory(std::shared_ptr<librealsense::context> const&, std::function<void (std::vector<std::shared_ptr<librealsense::device_info>, std::allocator<std::shared_ptr<librealsense::device_info> > > const&, std::vector<std::shared_ptr<librealsense::device_info>, std::allocator<std::shared_ptr<librealsense::device_info> > > const&)>&&)
2024-09-03T10:30:27.0531953Z #4    Object "/usr/lib/x86_64-linux-gnu/librealsense2.so.2.55.1", at 0x7f7b008b49dd, in librealsense::udev_device_watcher::udev_device_watcher(librealsense::platform::backend const*)
2024-09-03T10:30:27.0534854Z #3    Object "/usr/lib/x86_64-linux-gnu/librealsense2.so.2.55.1", at 0x7f7b0088d691, in librealsense::platform::usb_enumerator::query_devices_info()
2024-09-03T10:30:27.0537429Z #2    Object "/usr/lib/x86_64-linux-gnu/librealsense2.so.2.55.1", at 0x7f7b008811f1, in librealsense::platform::usb_context::usb_context()
2024-09-03T10:30:27.0561596Z #1    Object "/opt/HuarayTech/MVviewer/lib/libMVSDK.so.2.1.0.194984", at 0x7f7affe26a4c, in libusb_get_device_list
2024-09-03T10:30:27.0563715Z #0    Object "/usr/lib/x86_64-linux-gnu/libc.so.6", at 0x7f7aff497ef4, in pthread_mutex_lock
2024-09-03T10:30:27.0565057Z Segmentation fault (Address not mapped to object [0x30])
2024-09-03T10:30:27.1843933Z ./test.sh: line 11:  4338 Segmentation fault      (core dumped) $directory_path_of_this_script/build/main
```
