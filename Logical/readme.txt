This is a sample project to demonstrate how to execute a controlled shutdown of the PLC.
A controlled shutdown of the PLC ensures the integrity of the file system on the CF / CFast.

The sample project covers 2 use cases:
1. A buffer module, such as 0PB0200.1, is used to keep the 24VDC supply alive after a power failure. While running on the buffered 24VDC, the PLC performs a controlled shutdown.
2. The operator can trigger a controlled shutdown of the machine by pressing a button on the visualization.

System requirements:
- Automation runtime AR >= D4.63 or AR >= A4.73

Further information:
- 24VDC buffer module 0PB0200.1: https://www.br-automation.com/en/products/accessories/power-supplies/buffer-module/0pb02001/
- SYSreset() function, used to execute shutdown. AS help GUID: be301d61-d2d3-4b74-b331-911d77756932