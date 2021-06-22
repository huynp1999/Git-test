# Virtualization
Hay còn gọi là ảo hóa, là một công nghệ được nằm ở tầng trung gian giữa hệ thống phần cứng máy tính và phần mềm chạy trên nó.
Cho phép sử dụng tối đa công suất của ổ cứng hoặc một máy tính vật lý bằng cách phân phối cho nhiều người dùng hoặc nhiều môi trường độc lập.

Ví dụ:
- Có 3 server vật lý riêng biệt với những chức năng riêng của nó là: mail server, web server và các lagacy app nội bộ
- Tuy nhiên mỗi server chỉ dùng 30% công suất của chúng

![image](https://user-images.githubusercontent.com/83684068/122864278-878ce600-d34e-11eb-8cb2-e337e45ce756.png)

- Với ảo hóa, có thể tách mail server thành 2 phần riêng biệt với chức năng khác nhau
- Thậm chí, mailserver vẫn có thể tách được lần nữa để tận dụng tối đa tài nguyên sẵn có, từ 60% lên đến 90%

![image](https://user-images.githubusercontent.com/83684068/122864482-ebafaa00-d34e-11eb-8f77-6cd22d4f5e8a.png)

- Như vậy sẽ giảm được chi phí về phần cứng, chi phí bảo trì và làm mát cho các hệ thống server

**4 mục tiêu chính của ảo hóa**
- Availability: giúp các ứng dụng hoạt động liên tục bằng cách giảm thiểu, loại bỏ downtime khi gặp sự cố
- Scalability: khả năng tùy biến, thu hẹp hoặc mở rộng mô hình server dễ dàng mà không làm gián đoạn ứng dụng
- Optimization: sử dụng triệt để nguồn tài nguyên phần cứng và tránh lãng phí 
- Management: khả năng quản lý tập trung thuận tiện

