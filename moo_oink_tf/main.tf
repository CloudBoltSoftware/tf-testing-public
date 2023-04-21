

variable "content_a" {
    default = "moo! from the root directory"
}

variable "content_b" {
    default = "oink! from the root directory"
}

resource "local_file" "foo" {
    content     = var.content_a
    filename = "/tmp/content_a.txt"
}

resource "local_file" "bar" {
    content     = var.content_b
    filename = "/tmp/content_b.txt"
}
