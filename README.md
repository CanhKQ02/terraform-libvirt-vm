# Terraform + Libvirt: Tự động hoá triển khai VM Ubuntu trên KVM

> Dự án Infrastructure as Code (IaC) theo hướng production sử dụng Terraform để triển khai máy ảo Ubuntu trên KVM/libvirt với tự động hoá bằng cloud-init.
> 

```

## 1. Tổng quan

Dự án này minh hoạ cách xây dựng một hệ thống **triển khai VM có thể lặp lại, tự động hoá hoàn toàn** bằng:

- **Terraform** – quản lý hạ tầng dạng code (IaC)
- **KVM/libvirt** – nền tảng ảo hoá
- **Cloud-init** – cấu hình tự động khi VM khởi động lần đầu

### Tính năng chính

- Clone VM từ **golden image Ubuntu cloud**
- Tự động cấu hình toàn bộ (hostname, SSH, network, package)
- Triển khai nhiều VM bằng `for_each`
- Bảo mật mặc định (chỉ SSH key, không cho root login)
- Vòng đời sạch: tạo → xoá → tạo lại

```

## 2. Kiến trúc

Mỗi VM bao gồm 3 thành phần chính:

1. `ubuntu-base.qcow2`
    
    Ảnh gốc (golden image) được import vào storage pool
    
2. `<vm>.qcow2`
    
    Ổ đĩa runtime của VM, được clone từ ảnh gốc (`base_volume_id`)
    
3. `<vm>-cloudinit.iso`
    
    ISO chứa cấu hình cloud-init (`user_data`, `network_config`, `meta_data`) cho lần boot đầu
    

```

## 3. Cấu trúc thư mục

```jsx
terraform-vm/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── modules/
    └── vm/
        ├── main.tf
        ├── variables.tf
        └── cloud_init/
            ├── common.yml
            └── network.yml
```

## **4. Yêu cầu hệ thống**

- Linux host đã bật KVM/libvirt.
- Terraform phiên bản `>= 1.5`.
- Có quyền truy cập libvirt system daemon (`qemu:///system`).
- Có sẵn Ubuntu cloud image trên host.
- Có SSH public key để inject vào VM.
- ---## ⚙️ Yêu cầu hệ thống-Linuxhostđãbật**KVM/libvirt**-Terraform>=1.5-Quyềntruycập`qemu:///system`-Ubuntucloudimage(qcow2)-SSHkey(`ssh-keygen-ted25519`)

## **5. Biến cấu hình quan trọng**

Thiết lập trong `terraform/terraform.tfvars`:

| **Biến** | **Ý nghĩa** |
| --- | --- |
| `base_image_path` | Đường dẫn Ubuntu cloud image |
| `pool_name`, `pool_path` | Tên và vị trí storage pool |
| `memory`, `vcpu`, `disk` | Tài nguyên VM |
| `network_name` | Mạng libvirt (thường `default`) |
| `network_interface_name` | Tên NIC trong guest (`ens3` hoặc `enp1s0`) |
| `vm1_ip_cidr`, `network_gateway`, `network_dns` | Cấu hình IP tĩnh |
| `password` | Mật khẩu khởi tạo user `devops` (sensitive) |

## 6. Triển khai nhanh

```jsx
## khởi tạo terraform
terraform init

## Bật network libvirt 
virsh net-start default
virsh net-autostart default

## Apply hạ tầng
terraform plan
terraform apply
```

---

SSH vào VM

```bash
ssh assmin@192.168.122.50
```

---

## 7. Thiết kế bảo mật

- Disable root login
- Disable SSH password (`ssh_pwauth: false`)
- Chỉ dùng SSH key
- User sudo không phải root (`assmin`)
- VM dạng headless (không GUI)

---

## 8. Dọn tài nguyên

```bash
## xóa tài nguyên
terraform destroy
```

⚠️ Lưu ý:

Base image được bảo vệ:

```hcl
lifecycle {
  prevent_destroy = true
}
```

---

Dọn sạch hoàn toàn (manual)

Khi muốn reset từ đầu:

```bash
# Xoá VM nếu còn tồn tại
virsh destroy master
virsh undefine master# Xoá disk và cloud-initrm -f /kvm-storage/*.qcow2rm -f /kvm-storage/*cloudinit.iso
```

---

Tạo lại môi trường

```bash
terraform apply
```

---

## 9. Lỗi thường gặp

- **VM không có mạng**
→ Kiểm tra `network_interface_name`, gateway, subnet
- **Network default chưa bật**
    
    ```bash
    virsh net-start default
    ```
    
- **Không tạo được storage**
    
    → Kiểm tra pool:
    
    đảm bảo **, `pool_name`, `pool_path`	:** Tên và vị trí storage pool khớp với hệ thống của bạn
    
    ```bash
    virsh pool-list --all
    ```
    
- **Không SSH được**
→ Kiểm tra SSH key, IP trong VM, cloud-init

---

## 10. Hướng mở rộng

- Thêm DHCP mode (IP động)
- Hỗ trợ Bridge networking
- Kết hợp Ansible provisioning
- Thêm Makefile (`make apply/destroy`)
- CI/CD pipeline (GitHub Actions)

---

## Tài liệu tham khảo

Dự án được tham khảo từ:

- https://github.com/hoath2003/terraform_libvirt

Tuy nhiên đã được mở rộng và cải tiến:

- Refactor thành **kiến trúc module**
- Hỗ trợ **multi-VM với for_each**
- Nâng cấp cloud-init (user, SSH, network)
- Cải thiện output (IP, CPU, RAM, disk)
- Thêm troubleshooting thực tế
- Thiết kế lifecycle an toàn
